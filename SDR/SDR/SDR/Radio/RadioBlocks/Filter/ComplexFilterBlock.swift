//
//  FilterBlock.swift
//  SDR
//
//  Created by Davorin Mađarić on 08/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class ComplexFilterBlock {
    var inRate: Int = 1 {
        didSet {
            // create new down sample ratio
            self.downRatio = self.inRate / self.outRate
            
            // create new filter kernel
            self.kernel = FilterCoefficients.fir(sampleRate: self.inRate, frequency: self.frequency, length: self.kernel.count)
        }
    }
    
    var outRate: Int = 1 {
        didSet {
            self.downRatio = self.inRate / self.outRate
        }
    }
    
    var downRatio: Int = 1
    var frequency: Int
    
    var kernel: [Float]
    
    
    
    private let bufferSize: Int = 524288
    private var bufferSamples: DSP.ComplexSamples
    
    init(sampleRateIn: Int, sampleRateOut: Int, cutoffFrequency: Int, kernelLength: Int) {
        self.inRate = sampleRateIn
        self.outRate = sampleRateOut
        self.downRatio = sampleRateIn / sampleRateOut
        
        self.frequency = cutoffFrequency
        self.kernel = FilterCoefficients.fir(sampleRate: self.inRate, frequency: self.frequency, length: kernelLength)
        
        
        bufferSamples = DSP.ComplexSamples(count: bufferSize)
    }
    
    // TODO: Implement buffering as in FFT
    func process(_ samples: DSP.ComplexSamples) -> DSP.ComplexSamples {
        // Copy incomming samples to buffer
        bufferSamples.append(samples)
        
        
        
        
        // compute size of output buffer being: out = in.count / downRatio
        // if not evenly divisible, the remaining samples will be left over
        // for the next block of incoming samples
        var outBufferSize = samples.count / self.downRatio
        
        // compute input buffer size needed for vDSP_zrdesamp using:
        // input buffer size = (DF * (N - 1) + P)
        // https://developer.apple.com/reference/accelerate/1449946-vdsp_desamp
        let inBufferSize = (self.downRatio * (outBufferSize - 1)) + self.kernel.count
        
        if bufferSamples.count < inBufferSize {
            return samples
        }
        
        
        
        let sourceBuffer = DSP.ComplexSamples(count: inBufferSize)
        
        
        bufferSamples.move(to: sourceBuffer, count: inBufferSize)
        
        
        
        
        // create arrays for output samples
        let outSamples = DSP.ComplexSamples(count: outBufferSize)
        outSamples.count = outBufferSize
        
        // pack the input and output arrays into a DSPSplitComplex
        var source = bufferSamples.splitComplex()
        var dest = outSamples.splitComplex()
        
        // perform the decimation with FIR filter
        vDSP_zrdesamp(&source,
                      vDSP_Stride(self.downRatio),
                      &kernel,
                      &dest,
                      vDSP_Length(outBufferSize),
                      vDSP_Length(self.kernel.count))
        
        return outSamples
    }
}
