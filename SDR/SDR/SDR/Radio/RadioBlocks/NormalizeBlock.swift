//
//  NormalizeBlock.swift
//  SDR
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class NormalizeBlock: RadioBlock {
    var queue: OperationQueue?
    
    
    
    init(bits: Int) {
        
        
        
    }
    
    func samplesIn(_ samplesIn: SDRSamples, _ samplesOut: ((SDRSamples) -> Void)) {
        <#code#>
    }
    
    func samplesIn(_ rawSamples: [Int], _ samplesOut: ((_ samples: SDRSamples) -> Void)) {
        // get samples count
        let sampleLength = vDSP_Length(rawSamples.count)
        let sampleCount  = rawSamples.count
        
        // create stride constants
        let strideOfOne = vDSP_Stride(1)
        
        // create scalers
        var addScaler:  Double = -127.5
        var divScaler:  Double = 127.5
        
        // create Double array
        var doubleSamples: [Double] = [Double](repeating: 0.0, count: sampleCount)
        
        // convert the raw UInt8 values into Doubles
        vDSP_vfltu8D(rawSamples, strideOfOne, &doubleSamples, strideOfOne, sampleLength)
        
        // convert 0.0 ... 255.0 -> -127.5 ... 127.5
        vDSP_vsaddD(doubleSamples, strideOfOne, &addScaler, &doubleSamples, strideOfOne, sampleLength)
        
        // normalize values to -1.0 -> 1.0
        vDSP_vsdivD(doubleSamples, strideOfOne, &divScaler, &doubleSamples, strideOfOne, sampleLength)
        
        // create samples object
        guard let sdrSamples = SDRSamples(doubleSamples) else {
            print("ERROR SDRSamples(doubleSamples")
            return
        }
        
        samples.raise(sdrSamples)
        
        
        
        
    }
    
    
}
