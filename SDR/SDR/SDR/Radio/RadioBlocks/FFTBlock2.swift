//
//  FFTBlock2.swift
//  SDR
//
//  Created by Davorin Madaric on 12/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class FFTBlock2 {
    private let fftSize: Int = 131072
    private let fft: DSP.FFT2
    
    private let samplesBufferSize: Int = 524228
    private let realSamples: FifoQueue<Float>
    private let imagSamples: FifoQueue<Float>
    
    var fftData: (([Float]) -> Void)?
    
    init() {
        self.fft = DSP.FFT2(nFrames: UInt(fftSize), zeroPad: 0)
        
        self.realSamples = FifoQueue<Float>(size: samplesBufferSize)
        self.imagSamples = FifoQueue<Float>(size: samplesBufferSize)
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------
    
    func process(_ samples: DSPSamples) -> DSPSamples {
        // Add samples to local buffer
        self.realSamples.push(samples.real)
        self.imagSamples.push(samples.imag)
        
        // TODO: Implement buffer, fill buffer to fft size, then take those samples out, what is left takes another pass
        
        // copy samples
        
        if self.realSamples.count < self.fftSize || self.imagSamples.count < self.fftSize {
            return samples
        }
        
        var real = self.realSamples.pop(self.fftSize)
        var imag = self.imagSamples.pop(self.fftSize)
        
        self.fft.process(data: <#T##UnsafePointer<Float>#>)
        
        fftData?(dbs)
        
        return samples
    }
}
