//
//  DSP+Split.swift
//  SDR
//
//  Created by Davorin Mađarić on 10/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

extension DSP {
    /**
     Split array into smaller subarrays.
     
     - Parameters:
     - x: the input array.
     - numberOfParts: number of splits.
     
     - Returns: array of array of each split.
     
     #### Example
     ```
     let arr:[Double] = (1...6).map {Double($0)}
     
     splitArrayIntoParts(arr, 3)
     /// [[1, 2], [3, 4], [5, 6]]
     ```
     */
    class func splitArrayIntoParts(_ x:[Double], _ numberOfParts: Int) -> [[Double]] {        
        var parts = [[Double]]()
        let input = [Double](x)
        let samplesPerSplit = Int(round(Double(x.count)/Double(numberOfParts)))
        
        var startIndex:Int
        var endIndex:Int
        var slice:ArraySlice<Double>
        for i in 1..<numberOfParts {
            startIndex = (i-1)*samplesPerSplit
            endIndex = i*samplesPerSplit
            slice = input[startIndex..<endIndex]
            parts.append([Double](slice))
        }
        
        startIndex = (numberOfParts-1)*samplesPerSplit
        endIndex = x.count
        slice = input[startIndex..<endIndex]
        parts.append([Double](slice))
        
        return parts
    }
    
    /**
     Split array into smaller subarrays.
     
     - Parameters:
     - x: the input array.
     - numberOfParts: number of splits.
     
     - Returns: array of array of each split.
     
     #### Example
     ```
     let arr:[Double] = (1...6).map {Double($0)}
     
     splitArrayIntoParts(arr, 3)
     /// [[1, 2], [3, 4], [5, 6]]
     ```
     */
    class func splitArrayIntoParts(_ x:[Float], _ numberOfParts: Int) -> [[Float]] {
        var parts = [[Float]]()
        let input = [Float](x)
        let samplesPerSplit = Int(round(Double(x.count)/Double(numberOfParts)))
        
        var startIndex:Int
        var endIndex:Int
        var slice:ArraySlice<Float>
        for i in 1..<numberOfParts {
            startIndex = (i-1)*samplesPerSplit
            endIndex = i*samplesPerSplit
            slice = input[startIndex..<endIndex]
            parts.append([Float](slice))
        }
        
        startIndex = (numberOfParts-1)*samplesPerSplit
        endIndex = x.count
        slice = input[startIndex..<endIndex]
        parts.append([Float](slice))
        
        return parts
    }
}
