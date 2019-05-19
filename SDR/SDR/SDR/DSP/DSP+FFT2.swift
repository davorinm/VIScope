//
//  FFT.swift
//  Auditor
//
//  Created by Lance Jabr on 6/25/18.
//  Copyright © 2018 Lance Jabr. All rights reserved.
//

import Foundation
import Accelerate

extension DSP {
    /// A real-to-complex FFT processor using the Accelerate framework.
    class FFT2 {
        /// The number of real, time-domain samples that will be processed in each frame.
        let nFrames: UInt
        
        /// The number of zeros to add to the signal data on each frame.
        let zeroPad: UInt
        
        /// A struct used by Accelerate to perform the DFT.
        private let fftSetup: vDSP_DFT_Setup
        
        /// incoming data is fed into this buffer
        private var input: [Float]
        
        /// The windowing object of this FFT
        var windower: Windower?
        
        /// This object can eat samples at any rate–you don't have to pass in the same number of frames each time. When a new chunk of data has been processed, this will be set to `true`. You can set it to `false` to indicate you have used that output data.
        var newOutput = false
        
        /// After a call to `process`, this will contain the complex scaled FFT output.
        var fftOutput: DSPSplitComplex
        
        /// After a call to `process`, this will contain the power (mag^2) spectrum.
        var powerSpectrum: [Float]
        
        /// - parameter nFrames: The number of Floats that will be passed in on each call to `process`.
        /// - parameter zeroPad: The number of zeros that should be added to the end of passed in data. `nFrames + zeroPad` must be a power of 2.
        init(nFrames: UInt, zeroPad: UInt) {
            
            self.nFrames = nFrames
            self.zeroPad = zeroPad
            
            let totalLength = nFrames + zeroPad
            
            // create the Accelerate helper struct
            self.fftSetup = vDSP_DFT_zrop_CreateSetup(nil, vDSP_Length(totalLength / 2), .FORWARD)!
            
            // allocate space for the complex output
            let n_2 = Int((totalLength) / 2)
            self.fftOutput = DSPSplitComplex(realp: UnsafeMutablePointer<Float>.allocate(capacity: n_2),
                                             imagp: UnsafeMutablePointer<Float>.allocate(capacity: n_2))
            self.fftOutput.realp.initialize(repeating: 0, count: n_2)
            self.fftOutput.imagp.initialize(repeating: 0, count: n_2)
            
            // allocate space for the power spectrum
            self.powerSpectrum = [Float](repeating: 0, count: n_2)
            
            // create the windowing object
            self.windower = Windower(length: self.nFrames, function: .blackman)
            
            // allocate space for input
            self.input = [Float](repeating: 0, count: Int(self.nFrames))
        }
        
        deinit {
            vDSP_DFT_DestroySetup(self.fftSetup)
        }
        
        
    }
}
