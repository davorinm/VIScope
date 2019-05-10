//
//  DSP+Normalize.swift
//  SDR
//
//  Created by Davorin Mađarić on 10/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

extension DSP {
    /**
     Data normalization
     
     Normalize data to zero mean and unit standard deviation.
     
     - Parameters:
     - x: array of input data.
     
     - Returns: Normalized data which has zero mean and unit standard deviation.
     */
    class func normalize(_ x:[Double]) -> [Double] {
        var mean_x = DSP.mean(x)
        var std_x = DSP.std(x)
        
        var x_normalized = [Double](repeating: 0.0, count: x.count)
        
        vDSP_normalizeD(x, 1, &x_normalized, 1, &mean_x, &std_x, vDSP_Length(x.count))
        
        return x_normalized
    }
    
    /**
     Data normalization
     
     Normalize data to zero mean and unit standard deviation.
     
     - Parameters:
     - x: array of input data.
     
     - Returns: Normalized data which has zero mean and unit standard deviation.
     */
    class func normalize(_ x:[Float]) -> [Float] {
        var mean_x = DSP.mean(x)
        var std_x = DSP.std(x)
        
        var x_normalized = [Float](repeating: 0.0, count: x.count)
        
        vDSP_normalize(x, 1, &x_normalized, 1, &mean_x, &std_x, vDSP_Length(x.count))
        
        return x_normalized
    }
}
