//
//  DSP+FFTWindow.swift
//  SDR
//
//  Created by Davorin Madaric on 12/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

extension DSP {
    class FFTWindow {
        enum Function {
            case rectangular, blackman, hamming
        }
        
        /// The actual window data
        private var window: [Float]
        
        init(length: Int, function: Function) {
            self.window = [Float](repeating: 1, count: length)
            
            switch function {
            case .rectangular:
                break
            case .hamming:
                vDSP_hamm_window(&self.window, vDSP_Length(length), 0)
            case .blackman:
                vDSP_blkman_window(&self.window, vDSP_Length(length), 0)
            }
        }
        
        func process(data: UnsafeMutablePointer<Float>) {
            vDSP_vmul(self.window, 1, data, 1, data, 1, UInt(self.window.count))
        }
    }
}
