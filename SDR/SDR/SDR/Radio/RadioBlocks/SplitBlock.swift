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
    
    func process(_ samples: [Float]) -> DSPSamples {
        let count = samples.count / 2
        let output = DSPSamples(count: count)
        output.count = count
        
        var outputSC = DSPSplitComplex(realp: &output.real, imagp: &output.imag)
        
        // split the real data into a complex struct
        let samplesData = UnsafePointer<Float>(samples)
        samplesData.withMemoryRebound(to: DSPComplex.self, capacity: count) { dspComplex in
            vDSP_ctoz(dspComplex, 2, &outputSC, 1, UInt(count))
        }
        
        return output
    }
}
