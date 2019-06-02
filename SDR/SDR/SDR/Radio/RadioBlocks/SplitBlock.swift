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
        let output = DSP.ComplexSamples(count: count)
        var splitOutput = output.splitComplex()
        
        // split the real data into a complex struct
        let samplesData = UnsafePointer<Float>(samples)
        samplesData.withMemoryRebound(to: DSPComplex.self, capacity: count) { dspComplex in
            vDSP_ctoz(dspComplex, 2, &splitOutput, 1, UInt(count))
        }
        
        output.count = count
        
        return output
    }
}
