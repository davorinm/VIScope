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
    
    var notifyQueue: DispatchQueue?
    
    var inRate: Int = 1 {
        didSet {
            // create new down sample ratio
            self.downRatio = self.inRate / self.outRate
            
            // create new filter kernel
            self.kernel = FilterCoefficients.fir(sampleRate: self.inRate, frequency: self.frequency, length: self.kernelLength)
        }
    }
    
    var outRate:            Int = 1 {
        didSet {
            self.downRatio = self.inRate / self.outRate
        }
    }
    
    var downRatio:          Int = 1
    var frequency:          Int
    var kernelLength:       Int {
        return kernel.count
    }
    var kernel:             [Float]
    
    var realLastSamples:    [Float]
    var imagLastSamples:    [Float]
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------
    
    init(sampleRateIn: Int, sampleRateOut: Int, cutoffFrequency: Int, kernelLength: Int) {
        self.inRate         = sampleRateIn
        self.outRate        = sampleRateOut
        self.downRatio      = sampleRateIn / sampleRateOut
        
        self.frequency      = cutoffFrequency
        self.kernel         = FilterCoefficients.fir(sampleRate: self.inRate, frequency: self.frequency, length: kernelLength)
        
        // start the last samples buffer with 0s
        self.realLastSamples   = [Float](repeating :0.0, count: self.kernel.count)
        self.imagLastSamples   = [Float](repeating :0.0, count: self.kernel.count)
    }
    
    // TODO: Implement buffering as in FFT
    func process(_ samples: DSP.ComplexSamples) -> DSP.ComplexSamples {
        // compute size of output buffer being: out = in.count / downRatio
        // if not evenly divisible, the remaining samples will be left over
        // for the next block of incoming samples
        var outBufferSize = samples.count / self.downRatio
        
        // check if there are enough left over samples to create an
        // additional output sample
        if(realLastSamples.count > (self.kernelLength + self.downRatio)) {
            outBufferSize += 1
        }
        
        // compute input buffer size needed for vDSP_zrdesamp using:
        // input buffer size = (DF * (N - 1) + P)
        // https://developer.apple.com/reference/accelerate/1449946-vdsp_desamp
        let inBufferSize = (self.downRatio * (outBufferSize - 1)) + self.kernelLength
        
        // insert unconsumed samples from last block
        samples.real.insert(contentsOf: self.realLastSamples, at: 0)
        samples.imag.insert(contentsOf: self.imagLastSamples, at: 0)
        
        // clear the last samples buffer
        self.realLastSamples.removeAll(keepingCapacity: true)
        self.imagLastSamples.removeAll(keepingCapacity: true)
        
        // get the needed number of samples for vDSP_desamp: source[ 0 ... (DF * (N-1) + P)]
        // FIXME: Sample Rate Change
        // this will check if there are enough samples to process, if not
        // skip this set of samples.  This happens when the sample rate is changed
        // mid stream and inBufferSize is greater than the number of samples available
        // -- There should be a better way of doing this
        if(inBufferSize > samples.count) {
            realLastSamples = samples.real
            imagLastSamples = samples.imag
            fatalError("skipping samples")
        }
        
        var realSamples: [Float] = Array(samples.real.prefix(upTo: inBufferSize))
        var imagSamples: [Float] = Array(samples.imag.prefix(upTo: inBufferSize))
        
        // get the remaining samples which will be: source[ (DF * N) ... lastIndex]
        realLastSamples = Array(samples.real.dropFirst(self.downRatio * outBufferSize))
        imagLastSamples = Array(samples.imag.dropFirst(self.downRatio * outBufferSize))
        
        // create arrays for output samples
        let outSamples = DSP.ComplexSamples(count: outBufferSize)
        
        // pack the input and output arrays into a DSPSplitComplex
        var source = DSPSplitComplex(realp: &realSamples,    imagp: &imagSamples  )
        var dest   = outSamples.splitComplex()
        
        
        // perform the decimation with FIR filter
        vDSP_zrdesamp(
            &source,
            vDSP_Stride(self.downRatio      ),
            &kernel,
            &dest,
            vDSP_Length(outBufferSize       ),
            vDSP_Length(self.kernelLength   )
        )
        
        return outSamples
    }
}
