//
//  SoftwareDefinedRadioOld.swift
//  waveSDR
//
//  Copyright © 2017 GetOffMyHack. All rights reserved.
//

import Foundation
import Accelerate
import AVFoundation

class SoftwareDefinedRadioOld {
    
    static let audioSampleRate = 48000
    
    var workQueue:          DispatchQueue = DispatchQueue(label: "SoftwareDefinedRadioOld.WorkQueue")

    var selectedDevice: SDRDevice?
    
    var deviceList:             [SDRDevice] = []
    
    var isRunning:              Bool    = false
    
    var isPaused:               Bool    = false
    
    var deviceCount:            Int     = 0

    var frequency:              Int     = 0 {
        didSet {
            if let sdr = selectedDevice {
                workQueue.async {
                    sdr.tunedFrequency(frequency: self.frequency)
                }
            }
        }
    }
    
    var frequencyCorrection:    Int    = 0 {
        didSet {
            if let sdr = selectedDevice {
                sdr.frequencyCorrection(correction: self.frequencyCorrection)
            }
        }
    }
    
    var highPassCutoff:    Int    = 0 {
        didSet {
            self.audioFilterParams.frequency = Float(self.highPassCutoff)
        }
    }
    
    var highPassBypass:    Bool    = false {
        didSet {
            self.audioFilterParams.bypass = self.highPassBypass
        }
    }
    
    var sampleRate:             Int    = 2400000 {
        didSet {
            if let sdr = selectedDevice {
                sdr.sampleRate(rate: self.sampleRate)
            }
            if let radio = self.radio {
                radio.updateIFSampleRate(rate: self.sampleRate)
            }
        }
    }
    
    var tunerAutoGain:          Bool   = false {
        didSet {
            if let sdr = selectedDevice {
                sdr.tunerAutoGain(auto: self.tunerAutoGain)
            }
        }
    }
    
    var tunerGain:              Int    = 0 {
        didSet {
            if let sdr = selectedDevice {
                sdr.tunerGain(gain: self.tunerGain)
            }
        }
    }
    
    var squelchValue:           Float = 0.0 {
        didSet {
            self.radio?.updateSquelch(value: squelchValue)
        }
    }
    
    var localOscillator:        Int = 0 {
        didSet {
            self.radio?.updateMixer(oscillator: localOscillator)
            self.radio?.resetToneDecoder();
        }
    }
    
    var radio:                  RadioOld? {
        didSet {
            // since the radio blocks contain hard links to the next, the teardown()
            // methed is used to tell each block to unlink itself from the
            // next (via the samplesOut function)
            if let radio = oldValue {
                radio.teardown()
            }

        }
    }
    
    var radioQueue:         DispatchQueue

    private var _index:     Int                 = 0
    var sampleIndex:        Int {
        get {
            var index: Int!
            self.bufferQueue.sync {
                index = self._index
            }
            return index
        }
        
        set {
            self.bufferQueue.async {
                self._index = newValue
            }
        }

    }
    
    var sampleBuffer:       [[UInt8]]           = []

    var bufferQueue:        DispatchQueue       = DispatchQueue(label: "com.getoffmyhack.waveSDR.SoftwareDefinedRadioOld.bufferQueue")
    var dequeueQueue:       DispatchQueue       = DispatchQueue(label: "com.getoffmyhack.waveSDR.SoftwareDefinedRadioOld.dequeueQueue")
    
    // The audio engine manages the sound system.
    let audioEngine:		AVAudioEngine		= AVAudioEngine()
    
    // The player node schedules the playback of the audio buffers.
    let audioPlayerNode:	AVAudioPlayerNode	= AVAudioPlayerNode()
    
    // filter node creates high-pass filter
    let audioFilterNode:    AVAudioUnitEQ       =  AVAudioUnitEQ(numberOfBands: 1)
    var audioFilterParams:  AVAudioUnitEQFilterParameters

    
    // Use standard non-interleaved PCM audio.
    let audioFormat:		AVAudioFormat		= AVAudioFormat(standardFormatWithSampleRate: 48000.0, channels: 1)!
    
    // audio buffer
    let audioBuffer:		AVAudioPCMBuffer	= AVAudioPCMBuffer()
    

    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    init() {
        
        radioQueue  = DispatchQueue(label: "com.getoffmyhack.wavesdr.sdrQueue", attributes: [])
        audioFilterParams = audioFilterNode.bands.first!

        //----------------------------------------------------------------------
        //
        // get a list of all SDR hardware devices currently installed
        //
        // currently this is hard coded to the RTLSDR devices, but will 
        // ultimatly be replaced with a plug-in architecture such that
        // any number of different hardware platforms can be enumerated
        //
        //----------------------------------------------------------------------

        let rtlsdrList = RTLSDR.deviceList()
        deviceList  += rtlsdrList
        deviceCount  = deviceList.count
        
        // configure audio system
        // Attach and connect the player node.
        audioFilterNode.bypass = false
        
        audioFilterParams.filterType = .highPass
        audioFilterParams.frequency = 500
        audioFilterParams.bypass = false
        
        audioEngine.attach(audioFilterNode)
        audioEngine.attach(audioPlayerNode)
        
        audioEngine.connect(audioPlayerNode, to: audioFilterNode, format: audioFormat)
        audioEngine.connect(audioFilterNode, to: audioEngine.mainMixerNode, format: audioFormat)
//        audioEngine.connect(audioFilterNode, to: audioEngine.outputNode, format: audioFormat)

        
        NotificationCenter.default.addObserver(
            self,
            selector:   #selector(observedAVAudioEngineConfigurationChangeNotification(_:)),
            name:       Notification.Name.AVAudioEngineConfigurationChange,
            object:     audioEngine
        )


    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func start() {

        // attempt to start the audio engine
        do {
            try audioEngine.start()
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
        
        // start the player node
        audioPlayerNode.play()
        
        // start streaming samples from device
        selectedDevice!.startSampleStream()
        
        // start watchdog timer
        
        // set sample index to start dequeuing samples
//        self.sampleIndex = 0
        
        
        self.isRunning = true
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func stop() {
        
        // stop SDR samples
        selectedDevice!.stopSampleStream()
        
        // stop audio player
        audioPlayerNode.stop()
        
        // stop audio system
        audioEngine.stop()

        self.isRunning = false
        
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func goLive() {
        
        self.sampleIndex = (self.sampleBuffer.endIndex - 1)
        self.isPaused = false
        
    }

    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------
    
    @objc func observedAVAudioEngineConfigurationChangeNotification(_ notification: Notification) {
        
        Swift.print("audio engine config changed!!")

        // stop audio player
        audioPlayerNode.stop()
        
        // stop audio system
        audioEngine.stop()
        
        do {
            try audioEngine.start()
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
        
        // start the player node
        audioPlayerNode.play()

    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func setMode(_ mode: String) {
        
        switch mode {
            case "AM":
                self.radio = RadioOld.amDemodulator(sampleRateIn: sampleRate, sampleRateOut: SoftwareDefinedRadioOld.audioSampleRate, frequency: localOscillator)
            case "NFM":
                self.radio = RadioOld.nfmDemodulator(sampleRateIn: sampleRate, sampleRateOut: SoftwareDefinedRadioOld.audioSampleRate, frequency: localOscillator)
            case "WFM":
                self.radio = RadioOld.wfmDemodulator(sampleRateIn: sampleRate, sampleRateOut: SoftwareDefinedRadioOld.audioSampleRate, frequency: localOscillator)
            default:
                self.radio = RadioOld.nfmDemodulator(sampleRateIn: sampleRate, sampleRateOut: SoftwareDefinedRadioOld.audioSampleRate, frequency: localOscillator)
        }
        
        // configure radio output method
        self.radio?.samplesOut = processAudio
        self.radio?.updateSquelch(value: squelchValue)
        
    }    
}

extension SoftwareDefinedRadioOld {

    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------
    
    func processAudio(samples: Samples) {
        
        var audioBuffer:		AVAudioPCMBuffer
        var audioBufferData:	UnsafeMutablePointer<Float>
        
        audioBuffer = AVAudioPCMBuffer(pcmFormat: self.audioFormat, frameCapacity: AVAudioFrameCount(samples.count))!
        audioBuffer.frameLength = AVAudioFrameCount(samples.count)
        
        audioBufferData = (audioBuffer.floatChannelData?[0])!
        
        // copy PCM data to audio buffer
        for i in 0..<samples.count {
            audioBufferData[i] = samples.audio[i]
        }
        
        self.audioPlayerNode.scheduleBuffer(audioBuffer)
        
    }
    
    
}
