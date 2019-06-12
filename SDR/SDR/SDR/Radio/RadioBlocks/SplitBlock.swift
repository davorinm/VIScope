//
//  SplitBlock.swift
//  SDR
//
//  Created by Davorin Madaric on 12/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class SplitBlock {
    
    init() {
        // TODO: Implement
    }
    
    func process(_ samples: [Float]) -> DSP.ComplexSamples {
        let count = samples.count / 2
        let output = DSP.ComplexSamples(capacity: count)
        // TODO: Find better solution
        output.count = count
        var splitOutput = output.splitComplex()
        
//        // split the real data into a complex struct
//        let samplesData = UnsafePointer<Float>(samples)
//        samplesData.withMemoryRebound(to: DSPComplex.self, capacity: count) { dspComplex in
//            vDSP_ctoz(dspComplex, 2, &splitOutput, 1, UInt(count))
//        }
        var samples = samples
        
        var zeroScaler: Float = 0.0
        
        vDSP_vsadd(&samples + 0, 2, &zeroScaler, &output.real, 1, vDSP_Length(count) )
        vDSP_vsadd(&samples + 1, 2, &zeroScaler, &output.imag, 1, vDSP_Length(count) )
        
        return output
    }
}
