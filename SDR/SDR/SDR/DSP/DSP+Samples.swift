//
//  DSP+Samples.swift
//  SDR
//
//  Created by Davorin Madaric on 19/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

extension DSP {
    class Samples {
        var real: [Float]
        var imag: [Float]
        var count: Int
        
        init(count: Int) {
            self.real = [Float](repeating: 0, count: count)
            self.imag = [Float](repeating: 0, count: count)
            self.count = 0
        }
        
        func append(_ samples: DSP.Samples) {
            vDSP_mmov(samples.real, &real + count, vDSP_Length(samples.count), 1, 0, 0)
            vDSP_mmov(samples.imag, &imag + count, vDSP_Length(samples.count), 1, 0, 0)
            count += samples.count
        }
        
        func move(to: DSP.Samples, count: Int) {
            // Copy
            vDSP_mmov(self.real, &to.real, vDSP_Length(count), 1, 0, 0)
            vDSP_mmov(self.imag, &to.imag, vDSP_Length(count), 1, 0, 0)
            
            // Remove copyed samples from bufferSamples
            let remainingLength = self.count - count
            vDSP_mmov(&self.real + count, &self.real, vDSP_Length(remainingLength), 1, 0, 0)
            vDSP_mmov(&self.imag + count, &self.imag, vDSP_Length(remainingLength), 1, 0, 0)
            
            self.count = remainingLength
        }
        
        func splitComplex() -> DSPSplitComplex {
            return DSPSplitComplex(realp: &self.real, imagp: &self.imag)
        }
    }
}
