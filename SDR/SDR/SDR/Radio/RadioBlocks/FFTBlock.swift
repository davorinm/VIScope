//
//  FMDemodulatorBlock.swift
//  waveSDR
//
//  Copyright © 2017 GetOffMyHack. All rights reserved.
//

import Foundation
import Accelerate

class FFTBlock {
    private let bufferSize: Int = 524288
    private var bufferSamples: DSPSamples
    
    private let fftSize: Int = 64000
    private let fftLength: vDSP_Length
    private var fftSamples: DSPSamples
    
    private let fftWindow: DSP.FFTWindow
    
    private let fftSetup: vDSP_DFT_Setup
    
    var fftData: (([Float]) -> Void)?
    
    private let processQueue: DispatchQueue = DispatchQueue(label: "FFTBlock")
    
    init() {
        // Calculate fftSize
        let log2N = vDSP_Length(log2f(Float(fftSize)))
        fftLength = vDSP_Length(Int(1 << log2N))
        
        // Create buffer
        bufferSamples = DSPSamples(count: bufferSize)
        
        // Create fft buffer
        fftSamples = DSPSamples(count: Int(fftLength))
        
        // Create window
        fftWindow = DSP.FFTWindow(length: Int(fftLength), function: .hamming)
        
        // Create setup
        fftSetup = vDSP_DFT_zop_CreateSetup(nil, fftLength, vDSP_DFT_Direction.FORWARD)!
    }
    
    deinit {
        // Destroy setup
        vDSP_DFT_DestroySetup(fftSetup)
    }

    func process(_ samples: DSPSamples) -> DSPSamples {
        // Copy incomming samples to buffer
        bufferSamples.append(samples)
        
        // FFT
        processQueue.async {
            while self.bufferSamples.count >= self.fftLength {
                self.calculateFFT()
            }
        }
        
        return samples
    }
    
    private func calculateFFT() {
        // Check length
        guard bufferSamples.count >= fftLength else {
            return
        }
        
        // Copy to fft buffer
        bufferSamples.move(to: fftSamples, count: Int(fftLength))
        
        // Windowing
        fftWindow.process(data: &fftSamples.real)
        fftWindow.process(data: &fftSamples.imag)
        
        // execute DFT
        vDSP_DFT_Execute(self.fftSetup, fftSamples.real, fftSamples.imag, &fftSamples.real, &fftSamples.imag)
        
        // create DSPSPlitComplex for FFT
        var inMagnitudes: DSPSplitComplex = DSPSplitComplex(realp: &fftSamples.real, imagp: &fftSamples.imag)
        
        // get magnitudes
        var magnitudes = [Float](repeating: 0, count: Int(fftLength))
        vDSP_zvmags(&inMagnitudes, 1, &magnitudes, 1, fftLength)
        
        // convert to dbFS
        var dbScale: Float32 = 1
        var dbs = [Float](repeating: 0.0, count: Int(fftLength))
        vDSP_vdbcon(&magnitudes, 1, &dbScale, &dbs, 1, fftLength, 0)
        
        
//        // normalization of ifft
//        var scale = Float(fftN)
//        var normalizedOutputRealp = [Float](repeating: 0.0, count: fftN)
//        var normalizedOutputImagp = [Float](repeating: 0.0, count: fftN)
//
//        vDSP_vsdiv(&outputRealp, 1, &scale, &normalizedOutputRealp, 1, vDSP_Length(fftN))
//        vDSP_vsdiv(&outputImagp, 1, &scale, &normalizedOutputImagp, 1, vDSP_Length(fftN))
//
        // return data
        fftData?(magnitudes)
    }
    
//    private func fft(real: [Float], imag: [Float]) {
//        let log2N = vDSP_Length(log2f(Float(real.count)))
//        let fftN = Int(1 << log2N)
//
//        // buffers.
//        var inputCoefRealp = [Float](real[0..<fftN])
//        var inputCoefImagp = [Float](imag[0..<fftN])
//        var outputRealp = [Float](repeating: 0.0, count: fftN)
//        var outputImagp = [Float](repeating: 0.0, count: fftN)
//
//        // execute.
//        vDSP_DFT_Execute(setup, &inputCoefRealp, &inputCoefImagp, &outputRealp, &outputImagp)
//
//        // normalization of ifft
//        var scale = Float(fftN)
//        var normalizedOutputRealp = [Float](repeating: 0.0, count: fftN)
//        var normalizedOutputImagp = [Float](repeating: 0.0, count: fftN)
//
//        vDSP_vsdiv(&outputRealp, 1, &scale, &normalizedOutputRealp, 1, vDSP_Length(fftN))
//        vDSP_vsdiv(&outputImagp, 1, &scale, &normalizedOutputImagp, 1, vDSP_Length(fftN))
//
//        return (normalizedOutputRealp, normalizedOutputImagp)
//    }
}
