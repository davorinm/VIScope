//
//  FileSDRDevice.swift
//  SDR
//
//  Created by Davorin Madaric on 29/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

final class FileSDRDevice: SDRDevice {
    
    var name: String = "FileSDRDevice"
    
    var samples: ObservableEvent<[Float]> = ObservableEvent()
    
    let minimumFrequency: Int = 35000000
    
    let maximumFrequency: Int = 1500000000
    
    var sampleRate: Int = 2000000
    
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
    
    var tunerAutoGain: Bool = false
    
    var tunerGain: Int = 0
    
    var isOpen: Bool = false
    
    var isConfigured: Bool = false
    
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
            //                self?.samples.raise(data)
            //            }
            
            
//            let data = self.signal(noiseAmount: 0.1, numSamples: 3000)
            
            
            let data = self.play(carrierFrequency: 700000, modulatorFrequency: 15000, modulatorAmplitude: 0.8)
//            let data = self.signal(noiseAmount: 1, numSamples: self.bufferSize)
            self.samples.raise(data)
        }
    }
    
    private func gen() -> [Float]  {
        let n = self.bufferSize / 4 // Should be power of two for the FFT
        let frequency1 = 4.0
        let phase1 = 0.0
        let amplitude1 = 1.0
        let seconds = 1.0
        let fps = Double(n)/seconds
        
        var sineWave = (0..<n).map {
            amplitude1 * sin(2.0 * .pi / fps * Double($0) * frequency1 + phase1)
        }
        
        var cosineWave = (0..<n).map {
            amplitude1 * cos(2.0 * .pi / fps * Double($0) * frequency1 + phase1)
        }
        
        var out: [Float] = []
        
        for i in 0..<n {
            out.append(Float(sineWave[i]))
            out.append(Float(cosineWave[i]))
        }
        
        return out
    }
    
    var generatorSamples = [Float](repeating: 0, count: Int(32768 * 2))
    
    private func play(carrierFrequency: Float32, modulatorFrequency: Float32, modulatorAmplitude: Float32) -> [Float]  {
        let unitVelocity = Float32(2.0 * Double.pi / Double(sampleRate))
        let carrierVelocity = carrierFrequency * unitVelocity
        let modulatorVelocity = modulatorFrequency * unitVelocity

        // Fill the buffer with new samples.
        var sampleTime: Float = 0
        
        for sampleIndex in 0..<self.generatorSamples.count {
            let index = Int(sampleIndex)
            let sample = sin(carrierVelocity * sampleTime + modulatorAmplitude * sin(modulatorVelocity * sampleTime))
            
            generatorSamples[index] = sample
            
            sampleTime += 1
        }
        
        return generatorSamples
    }
    
    private func signal(noiseAmount: Float, numSamples: Int) -> [Float] {
        let tau = Float.pi * 2
        
        let samples: [Float] = (0 ..< numSamples).map { i in
            let phase = Float(i) / Float(numSamples) * tau
            
            var signal = cos(phase * 1) * 1.0
            signal += cos(phase * 2) * 0.8
            signal += cos(phase * 4) * 0.4
            signal += cos(phase * 8) * 0.8
            signal += cos(phase * 16) * 1.0
            signal += cos(phase * 32) * 0.8
            signal += cos(phase * 64) * 0.8
            
            return signal
        }
        
        let s2: [Float] = samples.map { signal in
            let res: Float = signal + .random(in: -1...1) * noiseAmount
            return res
        }
        
        return s2
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
