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
    
    func process(_ rawSamples: [UInt8]) -> SDRCplxSamples {
        let normalizedSamples = DSP.oldNormalize(rawSamples)
        
        let deinter = DSP.deinterlaceSamples(normalizedSamples)
        
        // create samples object
        return SDRCplxSamples(real: deinter.i, imag: deinter.q)
    }
}
