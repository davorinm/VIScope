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
        // get samples count
        let sampleLength = vDSP_Length(rawSamples.count)
        let sampleCount  = rawSamples.count
        
        // create stride constants
        let strideOfOne = vDSP_Stride(1)
        let strideOfTwo = vDSP_Stride(2)
        
        // create scalers
        var addScaler:  Float = -127.5
        var divScaler:  Float = 127.5
        var zeroScaler: Float = 0.0
        
        // create Double array
        var normalizedSamples: [Float] = [Float](repeating: 0.0, count: sampleCount)
        
        // convert the raw UInt8 values into Doubles
        vDSP_vfltu8(rawSamples, strideOfOne, &normalizedSamples, strideOfOne, sampleLength)
        
        // convert 0.0 ... 255.0 -> -127.5 ... 127.5
        vDSP_vsadd(normalizedSamples, strideOfOne, &addScaler, &normalizedSamples, strideOfOne, sampleLength)
        
        // normalize values to -1.0 -> 1.0
        vDSP_vsdiv(normalizedSamples, strideOfOne, &divScaler, &normalizedSamples, strideOfOne, sampleLength)
        
        // create split arrays for complex separation
        var real: [Float] = [Float](repeating: 0.0, count: (sampleCount / 2) )
        var imag: [Float] = [Float](repeating: 0.0, count: (sampleCount / 2) )
        
        // the following two vDSP_vsadd calls are used only as a means of
        // optimizing a for loop used to separate the I and Q values into
        // their own arrays
        vDSP_vsadd(&(normalizedSamples) + 0, strideOfTwo, &zeroScaler, &real, strideOfOne, (sampleLength / 2) )
        vDSP_vsadd(&(normalizedSamples) + 1, strideOfTwo, &zeroScaler, &imag, strideOfOne, (sampleLength / 2) )
        
        // create samples object
        return SDRCplxSamples(real: real, imag: imag)
    }
}
