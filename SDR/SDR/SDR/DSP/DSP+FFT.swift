//
//  DSP+FFT.swift
//  SDR
//
//  Created by Davorin Mađarić on 10/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class DSPFFTSetup {
    fileprivate let setup: vDSP_DFT_Setup
    
    init(_ setup: vDSP_DFT_Setup) {
        self.setup = setup
    }
}

extension DSP {
    enum FFTDirection {
        case forward
        case inverse
    }
    
    class FFT {
        private let setup: vDSP_DFT_Setup
        
        init?(length: UInt, direction: FFTDirection) {
            let dftDirection: vDSP_DFT_Direction
            
            switch direction {
            case .forward:
                dftDirection = vDSP_DFT_Direction.FORWARD
            case .inverse:
                dftDirection = vDSP_DFT_Direction.INVERSE
            }
            
            // Create setup
            if let setup = vDSP_DFT_zop_CreateSetup(nil, vDSP_Length(length), dftDirection) {
                self.setup = setup
            } else {
                return nil
            }
        }
        
        deinit {
            // Destroy setup
            vDSP_DFT_DestroySetup(setup)
        }
        
        /**
         Complex-to-Complex Fast Fourier Transform.
         
         - Note: that we use radix-2 fft. As a result, it may process only partial input
         data depending on the # of data is of power of 2 or not.
         
         - Parameters:
         - realp: real part of input data
         - imagp: imaginary part of input data
         
         - Returns: `(realp:[Float], imagp:[Float])`: Fourier coeficients. It's a tuple with named
         attributes, `realp` and `imagp`.
         */
        func fft(_ realp: [Float], imagp: [Float]) -> (realp: [Float], imagp: [Float]) {
            let log2N = vDSP_Length(log2f(Float(realp.count)))
            let fftN = Int(1 << log2N)
            
            // buffers.
            var inputRealp = [Float](realp[0..<fftN])
            var inputImagp = [Float](imagp[0..<fftN])
            var fftCoefRealp = [Float](repeating: 0.0, count: fftN)
            var fftCoefImagp = [Float](repeating: 0.0, count: fftN)
            
            // execute.
            vDSP_DFT_Execute(setup, &inputRealp, &inputImagp, &fftCoefRealp, &fftCoefImagp)
            
            return (fftCoefRealp, fftCoefImagp)
        }
        
        /**
         Complex-to-Complex Inverse Fast Fourier Transform.
         
         - Note: we use radix-2 Inverse Fast Fourier Transform. As a result, it may process
         only partial input data depending on the # of data is of power of 2 or not.
         
         - Parameters:
         - realp: real part of input data
         - imagp: imaginary part of input data
         
         - Returns: `(realp:[Float], imagp:[Float])`: Fourier coeficients. It's a tuple with named
         attributes, `realp` and `imagp`.
         */
        func ifft(_ realp: [Float], imagp: [Float]) -> (realp: [Float], imagp: [Float]) {
            let log2N = vDSP_Length(log2f(Float(realp.count)))
            let fftN = Int(1 << log2N)
            
            // buffers.
            var inputCoefRealp = [Float](realp[0..<fftN])
            var inputCoefImagp = [Float](imagp[0..<fftN])
            var outputRealp = [Float](repeating: 0.0, count: fftN)
            var outputImagp = [Float](repeating: 0.0, count: fftN)
            
            // execute.
            vDSP_DFT_Execute(setup, &inputCoefRealp, &inputCoefImagp, &outputRealp, &outputImagp)
            
            // normalization of ifft
            var scale = Float(fftN)
            var normalizedOutputRealp = [Float](repeating: 0.0, count: fftN)
            var normalizedOutputImagp = [Float](repeating: 0.0, count: fftN)
            
            vDSP_vsdiv(&outputRealp, 1, &scale, &normalizedOutputRealp, 1, vDSP_Length(fftN))
            vDSP_vsdiv(&outputImagp, 1, &scale, &normalizedOutputImagp, 1, vDSP_Length(fftN))
            
            return (normalizedOutputRealp, normalizedOutputImagp)
        }
    }
    
    class FFTD {
        private let setup: vDSP_DFT_Setup
        
        init?(length: UInt, direction: FFTDirection) {
            let dftDirection: vDSP_DFT_Direction
            
            switch direction {
            case .forward:
                dftDirection = vDSP_DFT_Direction.FORWARD
            case .inverse:
                dftDirection = vDSP_DFT_Direction.INVERSE
            }
            
            // Create setup
            if let setup = vDSP_DFT_zop_CreateSetupD(nil, vDSP_Length(length), dftDirection) {
                self.setup = setup
            } else {
                return nil
            }
        }
        
        deinit {
            // Destroy setup
            vDSP_DFT_DestroySetup(setup)
        }
        
        /**
         Complex-to-Complex Fast Fourier Transform.
         
         - Note: we use radix-2 fft. As a result, it may process only partial input
         data depending on the # of data is of power of 2 or not.
         
         - Parameters:
         - realp: real part of input data
         - imagp: imaginary part of input data
         
         - Returns:
         - `(realp:[Double], imagp:[Double])`: Fourier coeficients. It's a tuple with named
         attributes, `realp` and `imagp`.
         */
        func fftD(_ realp: [Double], imagp: [Double]) -> (realp: [Double], imagp: [Double]) {
            let log2N = vDSP_Length(log2f(Float(realp.count)))
            let fftN = Int(1 << log2N)
            
            // buffers
            var inputRealp = [Double](realp[0..<fftN])
            var inputImagp = [Double](imagp[0..<fftN])
            var fftCoefRealp = [Double](repeating: 0.0, count: fftN)
            var fftCoefImagp = [Double](repeating: 0.0, count: fftN)
            
            // execute
            vDSP_DFT_ExecuteD(setup, &inputRealp, &inputImagp, &fftCoefRealp, &fftCoefImagp)
            
            return (fftCoefRealp, fftCoefImagp)
        }
        
        /**
         Complex-to-Complex Inverse Fast Fourier Transform.
         
         - Note: we use radix-2 Inverse Fast Fourier Transform. As a result, it may process
         only partial input data depending on the # of data is of power of 2 or not.
         
         - Parameters:
         - realp: real part of input data
         - imagp: imaginary part of input data
         
         - Returns: `(realp:[Double], imagp:[Double])`: Fourier coeficients. It's a tuple with named
         attributes, `realp` and `imagp`.
         */
        func ifftD(_ realp: [Double], imagp: [Double]) -> (realp: [Double], imagp: [Double]) {
            let log2N = vDSP_Length(log2f(Float(realp.count)))
            let fftN = Int(1 << log2N)
            
            // buffers
            var inputCoefRealp = [Double](realp[0..<fftN])
            var inputCoefImagp = [Double](imagp[0..<fftN])
            var outputRealp = [Double](repeating: 0.0, count: fftN)
            var outputImagp = [Double](repeating: 0.0, count: fftN)
            
            // execute.
            vDSP_DFT_ExecuteD(setup, &inputCoefRealp, &inputCoefImagp, &outputRealp, &outputImagp)
            
            // normalization of ifft
            var scale = Double(fftN)
            var normalizedOutputRealp = [Double](repeating: 0.0, count: fftN)
            var normalizedOutputImagp = [Double](repeating: 0.0, count: fftN)
            
            vDSP_vsdivD(&outputRealp, 1, &scale, &normalizedOutputRealp, 1, vDSP_Length(fftN))
            vDSP_vsdivD(&outputImagp, 1, &scale, &normalizedOutputImagp, 1, vDSP_Length(fftN))
            
            return (normalizedOutputRealp, normalizedOutputImagp)
        }
    }
}
