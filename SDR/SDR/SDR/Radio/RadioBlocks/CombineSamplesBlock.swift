//
//  CombineSamplesBlock.swift
//  SDR
//
//  Created by Davorin Madaric on 28/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class CombineSamplesBlock {
    // TODO: use combine block for creating samples from multiple sources
    
    func process(_ samples: [DSP.ComplexSamples]) -> DSP.ComplexSamples {
        // Resample signals up
        
        // Shift signals
        
        // Add signals
        
        // Resample signals down
    
    
    
    
        return DSP.ComplexSamples(count: 4)
    }
    
    
    //
    
//    I simply took two RTL-SDR dongles at their max. band width of 2.4 MHz, resampled the signals to 4.8 MHz, then shifted the first signal down by 1MHz, the other one 1 MHz up, added them together, divided the combined signal by 2 and finally feed it into a FFT plot.
//
//    At first, I tried shifting the signals by 1.2 MHz to get full 4.8 MHz, but I realized, that I had a notch in the center, so I reduced the frequency shift until I had no notch anymore.
    
    //
    
//    //Upsampling - same as fft
//    vDSP_vgenp
//
//
//
//    vDSP_zmmul
//
//
//    //Vector multiply by scalar and add.
//    vDSP_zvsma
//
//    // Vector add.
//    vDSP_vadd
}
