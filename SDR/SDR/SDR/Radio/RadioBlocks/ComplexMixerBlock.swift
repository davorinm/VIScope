//
//  ComplexMixerBlock.swift
//  SDR
//
//  Created by Davorin Mađarić on 08/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class ComplexMixerBlock {
    var sampleRate: Int = 1 {
        didSet {
            self.δ = 2 * π * Float(self.localOscillator) / Float(self.sampleRate)
        }
    }
    
    var localOscillator: Int = 0 {
        didSet {
            self.δ = 2 * π * Float(self.localOscillator) / Float(self.sampleRate)
        }
    }
    
    let π: Float = .pi
    var δ: Float = 0.0
    var lastPhase: Float = 0.0
    
    init(sampleRate: Int, frequency: Int) {
        self.sampleRate = sampleRate
        self.localOscillator = frequency
        self.δ = 2 * π * Float(self.localOscillator) / Float(self.sampleRate)
    }
    
    func process(_ samples: DSP.ComplexSamples) -> DSP.ComplexSamples {
//        var samples = samples
        
        if (localOscillator != 0) {
            var inSamples = samples.splitComplex()
            
            //             δ=2πf/fs
            //             ϕ[n]=(ϕ[n−1]+δ) mod 2π
            
            var phaseArray:     [Float] = []
            var ϕ:   Float   = 0.0
            
            // create the phaseArray needed to create the complex oscillator
            for _ in 0..<samples.count {
                
                ϕ = δ + lastPhase
                ϕ.formRemainder(dividingBy: (2 * π))
                phaseArray.append(ϕ)
                lastPhase = ϕ
                
            }
            
            // create the oscillator
            // TODO: replace with vvcosisinf(_:​_:​_:​)
            
            var lo = DSP.ComplexSamples(capacity: samples.count)
            var oscillator: DSPSplitComplex = lo.splitComplex()
            var samplesCount: Int32 = Int32(samples.count)
            vvcosf(&lo.real, &phaseArray, &samplesCount)
            vvsinf(&lo.imag, &phaseArray, &samplesCount)
            lo.count = samples.count
            
//            vvcosisinf(&oscillator, &phaseArray, &samplesCount)
            
            // mix the original signal with the oscillator (in place)
            let conjugateMultiplication:    Int32 = -1
            vDSP_zvmul(
                &inSamples,
                vDSP_Stride(1),
                &oscillator,
                vDSP_Stride(1),
                &inSamples,
                vDSP_Stride(1),
                vDSP_Length(samplesCount),
                conjugateMultiplication
            )
            
        }
        
        return samples
    }
}
