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
    
    func process(_ rawSamples: [UInt8]) -> [Float] {
        // get samples count
        let sampleLength = vDSP_Length(rawSamples.count)
        let sampleCount  = rawSamples.count
        
        // create stride constants
        let strideOfOne = vDSP_Stride(1)
        
        // create scalers
        var addScaler:  Float = -127.5
        var divScaler:  Float = 127.5
        
        // create Double array
        var normalizedSamples: [Float] = [Float](repeating: 0.0, count: sampleCount)
        
        // convert the raw UInt8 values into Doubles
        vDSP_vfltu8(rawSamples, strideOfOne, &normalizedSamples, strideOfOne, sampleLength)
        
        // convert 0.0 ... 255.0 -> -127.5 ... 127.5
        vDSP_vsadd(normalizedSamples, strideOfOne, &addScaler, &normalizedSamples, strideOfOne, sampleLength)
        
        // normalize values to -1.0 -> 1.0
        vDSP_vsdiv(normalizedSamples, strideOfOne, &divScaler, &normalizedSamples, strideOfOne, sampleLength)
        
        // create samples object
        return normalizedSamples
    }
}
