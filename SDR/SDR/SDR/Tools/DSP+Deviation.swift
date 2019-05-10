//
//  DSP+Deviation.swift
//  SDR
//
//  Created by Davorin Mađarić on 10/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

extension DSP {
    /**
     Compute the standard deviation
     
     - Note: std = sqrt(variance(x))
     
     - Parameters:
     - x: the input data.
     
     - Returns: The standard deviation of x.
     */
    class func std(_ x:[Double]) -> Double {
        return sqrt(DSP.variance(x))
    }
    
    /**
     Compute the standard deviation
     
     - Note: std = sqrt(variance(x))
     
     - Parameters:
     - x: the input data.
     
     - Returns: The standard deviation of x.
     */
    class func std(_ x:[Float]) -> Float {
        return sqrt(DSP.variance(x))
    }
}
