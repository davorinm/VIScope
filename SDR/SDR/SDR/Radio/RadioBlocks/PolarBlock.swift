//
//  PolarBlock.swift
//  SDR
//
//  Created by Davorin Madaric on 03/06/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class PolarBlock {
    
    
    
    
    
    func process(_ samples: DSP.ComplexSamples) -> DSP.ComplexSamples {
        
        // For polar coordinates
        var mag: [Float] = [Float](repeating: 0, count: samples.count)
        var phase: [Float] = [Float](repeating: 0, count: samples.count)
        
        var source = samples.splitComplex()
        
        // ----------------------------------------------------------------
        // Convert from complex/rectangular (real, imaginary) coordinates
        // to polar (magnitude and phase) coordinates.
        // ----------------------------------------------------------------
        
        vDSP_zvabs(&source, 1, &mag, 1, vDSP_Length(samples.count))
        
        // Beware: Outputted phase here between -PI and +PI
        // https://developer.apple.com/library/prerelease/ios/documentation/Accelerate/Reference/vDSPRef/index.html#//apple_ref/c/func/vDSP_zvphasD
        vDSP_zvphas(&source, 1, &phase, 1, vDSP_Length(samples.count))
        
        
        return samples
    }
}
