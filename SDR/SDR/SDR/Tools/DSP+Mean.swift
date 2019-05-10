//
//  DSP+Mean.swift
//  SDR
//
//  Created by Davorin Mađarić on 10/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

extension DSP {
    /**
     Compute the arithmetic mean
     
     - Parameters:
     - x: array of data
     
     - Returns: the mean of elements in x.
     */
    class func mean(_ x:[Double]) -> Double {
        var value:Double = 0.0
        vDSP_meanvD(x, 1, &value, vDSP_Length(x.count))
        
        return value
    }
    
    /**
     Compute the arithmetic mean
     
     - Parameters:
     - x: array of data
     
     - Returns: the mean of elements in x.
     */
    class func mean(_ x:[Float]) -> Float {
        var value:Float = 0.0
        vDSP_meanv(x, 1, &value, vDSP_Length(x.count))
        
        return value
    }
}
