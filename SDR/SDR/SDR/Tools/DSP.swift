//
//  DSP.swift
//  SDR
//
//  Created by Davorin Mađarić on 10/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class DSPSamples {
    var real: [Float]
    var imag: [Float]
    var count: Int
    
    init(count: Int) {
        self.real = [Float](repeating: 0, count: count)
        self.imag = [Float](repeating: 0, count: count)
        self.count = 0
    }
    
    func append(_ samples: DSPSamples) {
        vDSP_mmov(samples.real, &real + count, vDSP_Length(samples.count), 1, 0, 0)
        vDSP_mmov(samples.imag, &imag + count, vDSP_Length(samples.count), 1, 0, 0)
        count += samples.count
    }
    
    func move(to: DSPSamples, count: Int) {
        // Copy
        vDSP_mmov(self.real, &to.real, vDSP_Length(count), 1, 0, 0)
        vDSP_mmov(self.imag, &to.imag, vDSP_Length(count), 1, 0, 0)
        
        // Remove copyed samples from bufferSamples
        let remainingLength = self.count - count
        vDSP_mmov(&self.real + count, &self.real, vDSP_Length(remainingLength), 1, 0, 0)
        vDSP_mmov(&self.imag + count, &self.imag, vDSP_Length(remainingLength), 1, 0, 0)
        
        self.count = remainingLength
    }
}

class DSP {
    class func oldNormalize(_ rawSamples: [UInt8]) -> [Float] {
        // get samples count
        let sampleCount  = rawSamples.count
        let sampleLength = vDSP_Length(sampleCount)
        
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
        
        return normalizedSamples
    }
    
    class func deinterlaceSamples(_ normalizedSamples: [Float]) -> (i: [Float], q: [Float]) {
        var normalizedSamples = normalizedSamples
        
        // get samples count
        let sampleCount  = normalizedSamples.count
        let sampleLength = vDSP_Length(sampleCount)
        
        // create stride constants
        let strideOfOne = vDSP_Stride(1)
        let strideOfTwo = vDSP_Stride(2)
        
        // create scalers
        var zeroScaler: Float = 0.0
        
        // create split arrays for complex separation
        var real: [Float] = [Float](repeating: 0.0, count: (sampleCount / 2) )
        var imag: [Float] = [Float](repeating: 0.0, count: (sampleCount / 2) )
        
        // the following two vDSP_vsadd calls are used only as a means of
        // optimizing a for loop used to separate the I and Q values into
        // their own arrays
        vDSP_vsadd(&(normalizedSamples) + 0, strideOfTwo, &zeroScaler, &real, strideOfOne, (sampleLength / 2) )
        vDSP_vsadd(&(normalizedSamples) + 1, strideOfTwo, &zeroScaler, &imag, strideOfOne, (sampleLength / 2) )
        
        return (real, imag)
    }
}
