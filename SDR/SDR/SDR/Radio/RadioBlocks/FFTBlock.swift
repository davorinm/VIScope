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
    private var bufferSamples: DSP.Samples
    
    private let fftSize: Int = 100000
    private let fftLength: vDSP_Length
    private var fftSamples: DSP.Samples
    
    private let fftWindow: DSP.FFTWindow
    
    private let fftSetup: vDSP_DFT_Setup
    
    var fftData: (([Float]) -> Void)?
    
    
    private let strideOne = vDSP_Stride(1)
    
    private var magnitudes: [Float]
    
    private var dbScale: Float32
    private var dbs: [Float]
    
    var interpolatedWidth = 500 {
        didSet {
            setupInterpolation()
        }
    }
    private var interpolationControl: [Float]
    
    private let processQueue: DispatchQueue = DispatchQueue(label: "FFTBlock")
    
    init() {
        // Calculate fftSize
        let log2N = vDSP_Length(log2f(Float(fftSize)))
        fftLength = vDSP_Length(Int(1 << log2N))
        
        // Create buffer
        bufferSamples = DSP.Samples(count: bufferSize)
        
        // Create fft buffer
        fftSamples = DSP.Samples(count: Int(fftLength))
        
        // Create window
        fftWindow = DSP.FFTWindow(length: Int(fftLength), function: .hamming)
        
        // Create setup
        fftSetup = vDSP_DFT_zop_CreateSetup(nil, fftLength, vDSP_DFT_Direction.FORWARD)!
        
        // Create magnitudes array
        magnitudes = [Float](repeating: 0, count: Int(fftLength))
        
        // Create db
        dbScale = 0.8
        dbs = [Float](repeating: 0.0, count: Int(fftLength))
        
        // Create interpolation control
        interpolationControl = [Float](repeating: 0, count: Int(fftLength))
        setupInterpolation()
    }
    
    deinit {
        // Destroy setup
        vDSP_DFT_DestroySetup(fftSetup)
    }

    func process(_ samples: DSP.Samples) -> DSP.Samples {
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
//        fftWindow.process(data: &fftSamples.real)
//        fftWindow.process(data: &fftSamples.imag)
        
        // execute DFT
        vDSP_DFT_Execute(self.fftSetup, fftSamples.real, fftSamples.imag, &fftSamples.real, &fftSamples.imag)
        
        // create DSPSPlitComplex for FFT
        var inMagnitudes: DSPSplitComplex = fftSamples.splitComplex()
        
        // Calculate magnitudes
        vDSP_zvmags(&inMagnitudes, strideOne, &magnitudes, strideOne, fftLength)
        
        // convert to db
        vDSP_vdbcon(&magnitudes, strideOne, &dbScale, &dbs, strideOne, fftLength, 1)
        
        // Interpolation
        var interpolated = [Float](repeating: 0, count: interpolatedWidth)
        vDSP_vgenp(dbs, strideOne,
                   interpolationControl, strideOne,
                   &interpolated, strideOne,
                   vDSP_Length(interpolatedWidth),
                   fftLength)
        
        // return data
        fftData?(interpolated)
    }
    
    /// Create interpolation control
    private func setupInterpolation() {
        var base: Float = 0
        var end = Float(interpolatedWidth)
        vDSP_vgen(&base,
                  &end,
                  &interpolationControl, strideOne,
                  fftLength)
    }
}
