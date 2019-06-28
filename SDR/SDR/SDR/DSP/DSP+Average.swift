//
//  DSP+Average.swift
//  SDR
//
//  Created by Davorin Madaric on 26/06/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

extension DSP {
    class Average {
        private var avgDataInput: [Float]
        private var avgDataOutput: [Float]
        private var avgDataIndex: Int
        
        var length = 1025 {
            didSet {
                avgDataInput = [Float](repeating: 0, count: length)
                avgDataOutput = [Float](repeating: 0, count: length)
                avgDataIndex = 0
            }
        }
        
        init(length: Int) {
            self.length = length
            
            avgDataInput = [Float](repeating: 0, count: self.length)
            avgDataOutput = [Float](repeating: 0, count: self.length)
            avgDataIndex = 0
        }
        
        func process(_ data:  [Float], _ result: (( _ avgData: [Float]) -> Void)) {
            vDSP_vadd(data, 1, avgDataInput, 1, &avgDataInput, 1, vDSP_Length(length))
            avgDataIndex += 1
            
            if avgDataIndex >= 200 {
                vDSP_vclr(&avgDataOutput, 1, vDSP_Length(length))
                var i: Float = Float(avgDataIndex)
                
                vDSP_vsdiv(avgDataInput, 1, &i, &avgDataOutput, 1, vDSP_Length(length))
                
                vDSP_vclr(&avgDataInput, 1, vDSP_Length(length))
                avgDataIndex = 0
                
                result(avgDataOutput)
            }
        }
    }
}
