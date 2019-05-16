//
//  NormalizeBlock.swift
//  SDR
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class NormalizeBlock {
    
    init(bits: Int) {
        // TODO: Implement
    }
    
    func process(_ samples: [UInt8]) -> [Float] {
        let normalizedSamples = DSP.oldNormalize(samples)
        
        return normalizedSamples
    }
}
