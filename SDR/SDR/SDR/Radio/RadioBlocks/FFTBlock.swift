//
//  FMDemodulatorBlock.swift
//  waveSDR
//
//  Copyright © 2017 GetOffMyHack. All rights reserved.
//

import Foundation
import Accelerate

class FFTBlock {
    var fftData: ((DSP.RealSamples) -> Void)?
    
    private let bufferSize: Int = 524288
    private var bufferSamples: DSP.ComplexSamples
    
    private let fftLength: vDSP_Length
    private var fftSamples: DSP.ComplexSamples
    
    private let fftWindow: DSP.FFTWindow
    
    private let fftSetup: vDSP_DFT_Setup
    
    private var magnitudes: [Float]
    private var dbScale: Float32
    private var dbs: [Float]
    
    private let processQueue: DispatchQueue = DispatchQueue(label: "FFTBlock")
    
    init(fftPoints: Int) {
        // Calculate fftSize
        let log2N = vDSP_Length(log2f(Float(fftPoints)))
        fftLength = vDSP_Length(Int(1 << log2N))
        
        // Create buffer
        bufferSamples = DSP.ComplexSamples(capacity: bufferSize)
        
        // Create fft buffer
        fftSamples = DSP.ComplexSamples(capacity: Int(fftLength))
        
        // Create window
        fftWindow = DSP.FFTWindow(length: Int(fftLength), function: .hamming)
        
        // Create setup
        fftSetup = vDSP_DFT_zop_CreateSetup(nil, fftLength, vDSP_DFT_Direction.FORWARD)!
        
        // Create magnitudes array
        magnitudes = [Float](repeating: 0, count: Int(fftLength))
        
        // Create db
        dbScale = 0.8
        dbs = [Float](repeating: 0.0, count: Int(fftLength))
    }
    
    deinit {
        // Destroy setup
        vDSP_DFT_DestroySetup(fftSetup)
    }

    func process(_ samples: DSP.ComplexSamples) -> DSP.ComplexSamples {
        // Copy incomming samples to buffer
        bufferSamples.append(samples)
        
        // FFT
        processQueue.async {
            while self.bufferSamples.count >= self.fftLength {
                self.calculate()
            }
        }
        
        return samples
    }
    
    private func calculate() {
        // Check length
        guard bufferSamples.count >= fftLength else {
            print("Not enough samples")
            return
        }
        
        // Copy to fft buffer
        bufferSamples.move(to: fftSamples, count: Int(fftLength))
        
        // Windowing
        fftWindow.process(data: &fftSamples.real)
        fftWindow.process(data: &fftSamples.imag)
        
        // execute fft
        vDSP_DFT_Execute(self.fftSetup, fftSamples.real, fftSamples.imag, &fftSamples.real, &fftSamples.imag)
        
        // create DSPSPlitComplex for FFT
        var fftComplexSamples: DSPSplitComplex = fftSamples.splitComplex()
        
        // scale the output by 1/N
//        var scale = 1/Float(fftLength)
//        var zero: Float = 0
//        var normFactor = DSPSplitComplex(realp: &scale, imagp: &zero)
//        vDSP_zvzsml(&fftComplexSamples, 1, &normFactor, &fftComplexSamples, 1, fftLength)
        
        // Calculate magnitudes
        vDSP_zvmags(&fftComplexSamples, 1, &magnitudes, 1, fftLength)
        
        // convert to db
        vDSP_vdbcon(&magnitudes, 1, &dbScale, &dbs, 1, fftLength, 1)
        
        // return data
        fftData?(dbs)
    }
}
