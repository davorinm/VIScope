//
//  AudioBlock.swift
//  SDR
//
//  Created by Davorin Mađarić on 08/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import AVFoundation

class AudioBlock {
    
    // The audio engine manages the sound system.
    let audioEngine:        AVAudioEngine        = AVAudioEngine()
    
    // The player node schedules the playback of the audio buffers.
    let audioPlayerNode:    AVAudioPlayerNode    = AVAudioPlayerNode()
    
    // filter node creates high-pass filter
    let audioFilterNode:    AVAudioUnitEQ       =  AVAudioUnitEQ(numberOfBands: 1)
    var audioFilterParams:  AVAudioUnitEQFilterParameters
    
    
    // Use standard non-interleaved PCM audio.
    let audioFormat:        AVAudioFormat        = AVAudioFormat(standardFormatWithSampleRate: 48000.0, channels: 1)!
    
    // audio buffer
    let audioBuffer:        AVAudioPCMBuffer    = AVAudioPCMBuffer()
    
    init() {
        // configure audio system
        // Attach and connect the player node.
        audioFilterNode.bypass = false
        
        audioFilterParams = audioFilterNode.bands.first!
        
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
    
    func startAudio() {
        // attempt to start the audio engine
        do {
            try audioEngine.start()
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
        
        // start the player node
        audioPlayerNode.play()
    }
    
    func stopAudio() {
        // stop audio player
        audioPlayerNode.stop()
        
        // stop audio system
        audioEngine.stop()
    }
    
    func process(_ samples: DSP.RealSamples) {
        
        var audioBuffer:        AVAudioPCMBuffer
        var audioBufferData:    UnsafeMutablePointer<Float>
        
        audioBuffer = AVAudioPCMBuffer(pcmFormat: self.audioFormat, frameCapacity: AVAudioFrameCount(samples.count))!
        audioBuffer.frameLength = AVAudioFrameCount(samples.count)
        
        audioBufferData = (audioBuffer.floatChannelData?[0])!
        
        // copy PCM data to audio buffer
        for i in 0..<samples.count {
            audioBufferData[i] = samples[i]
        }
        
        self.audioPlayerNode.scheduleBuffer(audioBuffer)
    }
    
    @objc private func observedAVAudioEngineConfigurationChangeNotification(_ notification: Notification) {
        print("audio engine config changed!!")
        
        // Restart audio player
        self.stopAudio()
        self.startAudio()
    }
}
