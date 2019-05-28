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
    
    private var bufferSize:             Int          = 16384 * 2 // TODO: Check buffer size

    
    
    private var scheduledTimer: Timer!
    
    private let asyncReadQueue: DispatchQueue = DispatchQueue(label: "kjghasdkfgds")
    
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
        scheduledTimer = Timer.scheduledTimer(withTimeInterval: 0.015, repeats: true) { [weak self] (timer) in
            self?.generate()
        }
    }
    
    func stopSampleStream() {
        scheduledTimer.invalidate()
        scheduledTimer = nil
    }
    
    // MARK: - Random
    
    private func generate() {
        self.asyncReadQueue.async {
            
            //            if let data = self?.generateSamples() {
            //                self?.rawSamples.raise(data)
            //            }
            
            
            
            let data = self.play(carrierFrequency: 20000, modulatorFrequency: 200, modulatorAmplitude: 0.8)
//            let data = self.signal(noiseAmount: 1, numSamples: self.bufferSize)
            self.rawSamples.raise(data)
        }
    }
    
    
    let generatorSampleRate: Double = 200000
    var generatorSamples = [UInt8](repeating: 0, count: Int(32768 * 2))
    
    private func play(carrierFrequency: Float32, modulatorFrequency: Float32, modulatorAmplitude: Float32) -> [UInt8]  {
        let unitVelocity = Float32(2.0 * Double.pi / generatorSampleRate)
        let carrierVelocity = carrierFrequency * unitVelocity
        let modulatorVelocity = modulatorFrequency * unitVelocity

        // Fill the buffer with new samples.
        var sampleTime: Float = 0
        
        for sampleIndex in 0..<self.generatorSamples.count {
            let index = Int(sampleIndex)
            
            let sample = sin(carrierVelocity * sampleTime + modulatorAmplitude * sin(modulatorVelocity * sampleTime))
            
            let mapped = ((sample + 1) / 2) * 255
            
            let val = UInt8(mapped)
            
            
            generatorSamples[index] = val
            
            sampleTime += 1
        }
        
        return generatorSamples
    }
    
    private func signal(noiseAmount: Float, numSamples: Int) -> [UInt8] {
        let tau = Float.pi * 2
        
        let samples: [Float] = (0 ..< numSamples).map { i in
            let phase = Float(i) / Float(numSamples) * tau
            
            var signal = cos(phase * 1) * 1.0
            signal += cos(phase * 2) * 0.8
            signal += cos(phase * 4) * 0.4
            signal += cos(phase * 8) * 0.8
            signal += cos(phase * 16) * 1.0
            signal += cos(phase * 32) * 0.8
            
            return signal
        }
        
        let s2: [Float] = samples.map { signal in
            let res: Float = signal + .random(in: -1...1) * noiseAmount
            return res
        }
        
        let s3: [UInt8] = s2.map {
            let ddd = $0 + 5
            return UInt8(ddd * 23)
        }
        
        return s3
    }
    
    private func ttt() {
        let level = ((Float32(arc4random()) / exp2(32)) - Float32(0.5)) * Float32(2)
    }
    
    private func generateSamples() -> [UInt8] {
        let array = (0..<bufferSize).map { _ in UInt8.random(in: 10 ..< 230) }
        return array
    }
    
    // MARK: - Test
    
    let π = M_PI
    let sampleCount = 32000
    
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
