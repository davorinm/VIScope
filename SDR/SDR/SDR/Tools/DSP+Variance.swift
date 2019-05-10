//
//  DSP+Variance.swift
//  SDR
//
//  Created by Davorin Mađarić on 10/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

extension DSP {
    /**
     Compute the variance
     
     - Note: variance = mean(abs(x - mean_x)^2)
     
     - Parameters:
     - x: array of data
     
     - Returns: the variance of elements in x.
     */
    class func variance(_ x: [Double]) -> Double {
        let N = vDSP_Length(x.count)
        var input_buffer = [Double](repeating: 0.0, count: x.count)
        var neg_mean_x = -mean(x)
        
        vDSP_vsaddD(x, 1, &neg_mean_x, &input_buffer, 1, N)
        
        var output_buffer = [Double](repeating: 0.0, count: x.count)
        vDSP_vsqD(&input_buffer, 1, &output_buffer, 1, N)
        
        let result = output_buffer.reduce(0, {$0 + $1})
        
        return result/Double(x.count)
    }
    
    /**
     Compute the variance
     
     - Note: variance = mean(abs(x - mean_x)^2)
     
     - Parameters:
     - x: array of data
     
     - Returns: the variance of elements in x.
     */
    class func variance(_ x: [Float]) -> Float {
        let N = vDSP_Length(x.count)
        var input_buffer = [Float](repeating: 0.0, count: x.count)
        var neg_mean_x = -mean(x)
        
        vDSP_vsadd(x, 1, &neg_mean_x, &input_buffer, 1, N)
        
        var output_buffer = [Float](repeating: 0.0, count: x.count)
        vDSP_vsq(&input_buffer, 1, &output_buffer, 1, N)
        
        let result = output_buffer.reduce(0, {$0 + $1})
        
        return result/Float(x.count)
    }
}
