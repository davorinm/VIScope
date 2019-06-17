//
//  DSP+Map.swift
//  SDR
//
//  Created by Davorin Mađarić on 17/06/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

extension DSP {
    class func map(_ rawSamples: [UInt8]) -> [Float] {
        // get samples count
        let sampleCount  = rawSamples.count
        let sampleLength = vDSP_Length(sampleCount)
        
        // create scalers
        var addScaler:  Float = -127.5
        var divScaler:  Float = 127.5
        
        // create Double array
        var normalizedSamples: [Float] = [Float](repeating: 0.0, count: sampleCount)
        
        // convert the raw UInt8 values into Doubles
        vDSP_vfltu8(rawSamples, 1, &normalizedSamples, 1, sampleLength)
        
        // convert 0.0 ... 255.0 -> -127.5 ... 127.5
        vDSP_vsadd(normalizedSamples, 1, &addScaler, &normalizedSamples, 1, sampleLength)
        
        // normalize values to -1.0 -> 1.0
        vDSP_vsdiv(normalizedSamples, 1, &divScaler, &normalizedSamples, 1, sampleLength)
        
        return normalizedSamples
    }
}
