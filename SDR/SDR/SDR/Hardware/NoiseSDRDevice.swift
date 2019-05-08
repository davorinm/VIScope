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
    
    
    
    
    private var scheduledTimer: Timer!
    
    init() {
        
        
        
        
        
        
        
    }
    
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
        scheduledTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] (timer) in
            if let data = self?.generateSamples() {
                self?.rawSamples.raise(data)
            }
        }
    }
    
    func stopSampleStream() {
        scheduledTimer.invalidate()
        scheduledTimer = nil
    }
    
    // MARK: - Random
    
    private func ttt() {
        let level = ((Float32(arc4random()) / exp2(32)) - Float32(0.5)) * Float32(2)
    }
    
    private func generateSamples() -> [UInt8] {
        let array = (0..<32000).map { _ in UInt8.random(in: 100 ..< 155) }
        return array
    }
    
    // MARK: - Test
    
    let π = M_PI
    let sampleCount = 1024
    
    private func testSpectrumData() -> [Double] {
        //        let array = (0..<1000).map { _ in Int.random(in: 0 ..< 1000) }
        //
        //        let mapped = array.map { (val) -> Double in
        //            return Double(val) / 1000
        //        }
        //
        //        return mapped
        
        
        
        let t = (0..<sampleCount).map({ 2*π * Double($0) / Double(sampleCount - 1) })
        let y = t.map({ ((sin($0) + 1) / 2) })
        
        return y
    }
}
