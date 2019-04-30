//
//  NoiseSDRDevice.swift
//  SDR
//
//  Created by Davorin Madaric on 29/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

class NoiseSDRDevice: SDRDevice {
    
    var name: String = "NoiseSDRDevice"
    
    var rawSamples: ObservableEvent<[UInt8]> = ObservableEvent()
    
    let minimumFrequency: Int = 35000000
    
    let maximumFrequency: Int = 1500000000
    
    var sampleRate: Int = 0
    
    func sampleRateList() -> [Int] {
        return [2000000]
    }
    
    var tunedFrequency: Int = 100000000
    
    var frequencyCorrection: Int = 0
    
    func tunerGainArray() -> [Int] {
        return [0]
    }
    
    func tunerAutoGain() -> Bool {
        return false
    }
    
    func tunerAutoGain(auto: Bool) {
        
    }
    
    func tunerGain() -> Int {
        return 0
    }
    
    func tunerGain(gain: Int) {
        
    }
    
    func isOpen() -> Bool {
        return false
    }
    
    func isConfigured() -> Bool {
        return false
    }
    
    func startSampleStream() {
        
    }
    
    func stopSampleStream() {
        
    }
    
    // MARK: - Private
    
    private func generateSamples() -> [UInt8] {
        let array = (0..<300).map { _ in UInt8.random(in: 0 ..< 10) }
        return array
    }
}
