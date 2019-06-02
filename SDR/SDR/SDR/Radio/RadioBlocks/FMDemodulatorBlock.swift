//
//  FMDemodulatorBlock.swift
//  SDR
//
//  Created by Davorin Madaric on 02/06/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class FMDemodulatorBlock {
    // TODO: Remove last I, Q
    var lastI:      Float = 0.0
    var lastQ:      Float = 0.0
    
    let fmGain:     Float = 1.0
    
    init() {
        // TODO: Create audioSamples buffer in initialize
    }
    
    func process(_ samples: DSP.ComplexSamples) -> [Float] {
        // TODO: Create buffer in initialize
        var audioSamples: [Float] = []
        
        // demodulate to audio & add audio samples to samples object
        for idx in 0..<samples.count {
            let I = samples.real[idx]
            let Q = samples.imag[idx]
            
            let num = ( (I * lastQ) - (Q * lastI) )
            //        -----------------------------
            let den = (     (I * I) + (Q * Q)     ) + 0.0000000001 // add epsilon to avoid division by zero
            
            audioSamples.append(self.fmGain * (num / den))
            
            self.lastI = I
            self.lastQ = Q
        }
        
        // the reference to samplesOut may become nil at any time so
        // check to make sure it exists before sending samples out
        return audioSamples
    }
    
    //
    // demodulate FM
    //
    // takes iq samples and demodulates narrow FM
    //
    
    /*------------------------------------------------------------------------*\
     
     f[n]    = arg{x[n+1]} - arg{x[n]}
     
     = arctan(
     (Im{x[n+1]}*Re{x[n]} - Re{x[n+1]}*Im{x[n]})
     /
     (Re{x[n+1]}*Re{x[n]} + Im{x[n+1]}*Im{x[n]})
     )
     
     f[n] =    (IQ'-QI')
     ---------
     (I^2+Q^2)
     
     f = angle(x(2:N).*conj(x(1:N-1)))/2/pi;
     
     \*------------------------------------------------------------------------*/
    
    
}
