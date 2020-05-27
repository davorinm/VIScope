//
//  AudioProviderImpl.swift
//  ImpactWrapConsumer
//
//  Created by Davorin Mađarić on 08/05/2020.
//  Copyright © 2020 Inova. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import CoreAudio

class AudioProviderImpl: AudioProvider {
    let samplesData: ObservableEvent<AudioProviderData> = ObservableEvent<AudioProviderData>()
    
    private let sampleRate: Float
    private let numberOfChannels: Int
    private var shouldPerformDCOffsetRejection: Bool = false
    
    private var audioUnit: AudioUnit!
    private let inputBus: UInt32 = 1
    private let outputBus: UInt32 = 0
    
    init(sampleRate: Float = 44100.0, numberOfChannels: Int = 1) {
        self.sampleRate = sampleRate
        self.numberOfChannels = numberOfChannels
    }
    
    func configureAudioOutput(audioSamples: @escaping (() -> [Float])) {
        let kOutputUnitSubType = kAudioUnitSubType_RemoteIO
        
        let ioUnitDesc = AudioComponentDescription(
            componentType: kAudioUnitType_Output,
            componentSubType: kOutputUnitSubType,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0)
        
        guard
            let ioUnit = try? AUAudioUnit(componentDescription: ioUnitDesc,
                                          options: AudioComponentInstantiationOptions()),
            let outputRenderFormat = AVAudioFormat(
                standardFormatWithSampleRate: ioUnit.outputBusses[0].format.sampleRate,
                channels: 1) else {
                    print("Unable to create outputRenderFormat")
                    return
        }
        
        do {
            try ioUnit.inputBusses[0].setFormat(outputRenderFormat)
        } catch {
            print("Error setting format on ioUnit")
            return
        }
        
        ioUnit.outputProvider = { (
            actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
            timestamp: UnsafePointer<AudioTimeStamp>,
            frameCount: AUAudioFrameCount,
            busIndex: Int,
            rawBufferList: UnsafeMutablePointer<AudioBufferList>) -> AUAudioUnitStatus in
                        
            let bufferList = UnsafeMutableAudioBufferListPointer(rawBufferList)
            if !bufferList.isEmpty {
                let signal = audioSamples()
                
                bufferList[0].mData?.copyMemory(from: signal, byteCount: sampleCount * MemoryLayout<Float>.size)
            }
            
            return noErr
        }
        
        do {
            try ioUnit.allocateRenderResources()
        } catch {
            print("Error allocating render resources")
            return
        }
        
        do {
            try ioUnit.startHardware()
        } catch {
            print("Error starting audio")
        }
    }
    
    func startRecording() {
        checkPermissions()
        setupAudioSession()        
        setupAudioUnit()
        
        do {
            if self.audioUnit == nil {
                
            }
            
            try AVAudioSession.sharedInstance().setActive(true)
            var osErr: OSStatus = 0
            
            osErr = AudioUnitInitialize(self.audioUnit)
            assert(osErr == noErr, "*** AudioUnitInitialize err \(osErr)")
            osErr = AudioOutputUnitStart(self.audioUnit)
            assert(osErr == noErr, "*** AudioOutputUnitStart err \(osErr)")
        } catch {
            print("*** startRecording error: \(error)")
        }
    }
    
    func stopRecording() {
        do {
            var osErr: OSStatus = 0
            
            osErr = AudioUnitUninitialize(self.audioUnit)
            assert(osErr == noErr, "*** AudioUnitUninitialize err \(osErr)")
            
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("*** error: \(error)")
        }
    }
    
    // MARK: - Private
    
    private func checkPermissions() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            print("AVAudioSession.RecordPermission.granted")
        case AVAudioSession.RecordPermission.denied:
            print("AVAudioSession.RecordPermission.denied")
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { (allowed) in
                print("AVAudioSession.RecordPermission.allowed \(allowed)")
            }
            print("AVAudioSession.RecordPermission.undetermined")
        default:
            print("default")
        }
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        guard audioSession.availableCategories.contains(.record) else {
            print("can't record! bailing.")
            return
        }
        
        do {
            try audioSession.setCategory(.record)
            
            // "Appropriate for applications that wish to minimize the effect of system-supplied signal processing for input and/or output audio signals."
            // NB: This turns off the high-pass filter that CoreAudio normally applies.
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            
            try audioSession.setPreferredSampleRate(Double(sampleRate))
            
            // This will have an impact on CPU usage. .01 gives 512 samples per frame on iPhone. (Probably .01 * 44100 rounded up.)
            // NB: This is considered a 'hint' and more often than not is just ignored.
            try audioSession.setPreferredIOBufferDuration(0.01)
            
            audioSession.requestRecordPermission { (granted) -> Void in
                if !granted {
                    print("*** record permission denied")
                }
            }
        } catch {
            print("*** audioSession error: \(error)")
        }
    }
    
    private func setupAudioUnit() {
        var componentDesc: AudioComponentDescription = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO), // Always this for iOS.
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0
        )
        
        var osErr: OSStatus = 0
        
        // Get an audio component matching our description.
        let component: AudioComponent! = AudioComponentFindNext(nil, &componentDesc)
        assert(component != nil, "Couldn't find a default component")
        
        // Create an instance of the AudioUnit
        var tempAudioUnit: AudioUnit?
        osErr = AudioComponentInstanceNew(component, &tempAudioUnit)
        self.audioUnit = tempAudioUnit
        
        assert(osErr == noErr, "*** AudioComponentInstanceNew err \(osErr)")
        
        // Enable I/O for input.
        var one: UInt32 = 1
        
        osErr = AudioUnitSetProperty(audioUnit,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Input,
            inputBus,
            &one,
            UInt32(MemoryLayout<UInt32>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
        
        osErr = AudioUnitSetProperty(audioUnit,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Output,
            outputBus,
            &one,
            UInt32(MemoryLayout<UInt32>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
        
        // Set format to 32 bit, floating point, linear PCM
        var streamFormatDesc: AudioStreamBasicDescription = AudioStreamBasicDescription(
            mSampleRate: Double(sampleRate),
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved, // floating point data - docs say this is fastest
            mBytesPerPacket: 4,
            mFramesPerPacket: 1,
            mBytesPerFrame: 4,
            mChannelsPerFrame: UInt32(self.numberOfChannels),
            mBitsPerChannel: 4 * 8,
            mReserved: 0
        )
        
        // Set format for input bus
        osErr = AudioUnitSetProperty(audioUnit,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Output,
            inputBus,
            &streamFormatDesc,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
        
        // Set format for output bus
        osErr = AudioUnitSetProperty(audioUnit,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Input,
            outputBus,
            &streamFormatDesc,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
        
        // Set up our callback.
        var inputCallbackStruct = AURenderCallbackStruct(inputProc: recordingCallback, inputProcRefCon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        osErr = AudioUnitSetProperty(audioUnit,
            AudioUnitPropertyID(kAudioOutputUnitProperty_SetInputCallback),
            AudioUnitScope(kAudioUnitScope_Global),
            inputBus,
            &inputCallbackStruct,
            UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
        
        // Ask CoreAudio to allocate buffers for us on render. (This is true by default but just to be explicit about it...)
        osErr = AudioUnitSetProperty(audioUnit,
            AudioUnitPropertyID(kAudioUnitProperty_ShouldAllocateBuffer),
            AudioUnitScope(kAudioUnitScope_Output),
            inputBus,
            &one,
            UInt32(MemoryLayout<UInt32>.size))
        assert(osErr == noErr, "*** AudioUnitSetProperty err \(osErr)")
    }
    
    private let recordingCallback: AURenderCallback = { (inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData) -> OSStatus in
        let audioInput = unsafeBitCast(inRefCon, to: AudioProviderImpl.self)
        var osErr: OSStatus = 0
        
        // We've asked CoreAudio to allocate buffers for us, so just set mData to nil and it will be populated on AudioUnitRender().
        var bufferList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: AudioBuffer(
                mNumberChannels: UInt32(audioInput.numberOfChannels),
                mDataByteSize: 4,
                mData: nil))
        
        osErr = AudioUnitRender(audioInput.audioUnit,
            ioActionFlags,
            inTimeStamp,
            inBusNumber,
            inNumberFrames,
            &bufferList)
        assert(osErr == noErr, "*** AudioUnitRender err \(osErr)")
        
        // Move samples from mData into our native [Float] format.
        var monoSamples = [Float]()
        let ptr = bufferList.mBuffers.mData?.assumingMemoryBound(to: Float.self)
        monoSamples.append(contentsOf: UnsafeBufferPointer(start: ptr, count: Int(inNumberFrames)))
        
        if audioInput.shouldPerformDCOffsetRejection {
            audioInput.DCRejectionFilterProcessInPlace(&monoSamples, count: Int(inNumberFrames))
        }
        
        // Return data
        let data = AudioProviderData(timeStamp: inTimeStamp.pointee.mSampleTime / Double(audioInput.sampleRate),
                                     numberOfFrames: Int(inNumberFrames),
                                     samples: monoSamples)
        audioInput.samplesData.raise(data)
        
        return 0
    }
    
    // MARK: - DC Filter
    
    private func DCRejectionFilterProcessInPlace(_ audioData: inout [Float], count: Int) {
        let defaultPoleDist: Float = 0.975
        var mX1: Float = 0
        var mY1: Float = 0
        
        for i in 0..<count {
            let xCurr: Float = audioData[i]
            audioData[i] = audioData[i] - mX1 + (defaultPoleDist * mY1)
            mX1 = xCurr
            mY1 = audioData[i]
        }
    }
}
