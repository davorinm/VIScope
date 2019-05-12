//
//  FMDemodulatorBlock.swift
//  waveSDR
//
//  Copyright © 2017 GetOffMyHack. All rights reserved.
//

import Foundation
import Accelerate

class FFTBlock {
    private let fftSize: Int = 131072
    private let fft: DSP.FFT
    private let fftWindow: DSP.FFTWindow
    
    private let samplesBufferSize: Int = 524228
    private let realSamples: FifoQueue<Float>
    private let imagSamples: FifoQueue<Float>
    
    var fftData: (([Float]) -> Void)?
    
    init() {
        self.realSamples = FifoQueue<Float>(size: samplesBufferSize)
        self.imagSamples = FifoQueue<Float>(size: samplesBufferSize)
        
        let fftLength:  vDSP_Length = vDSP_Length(log2(Float(fftSize)))
        
        self.fftWindow = DSP.FFTWindow(length: fftSize, function: .hamming)
        self.fft = DSP.FFT(length: fftLength, direction: .forward)!
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func process(_ samples: DSPSamples) -> DSPSamples {
        // Add samples to local buffer
        self.realSamples.push(samples.real)
        self.imagSamples.push(samples.imag)
        
        // TODO: Implement buffer, fill buffer to fft size, then take those samples out, what is left takes another pass
        
        // copy samples
        
        if self.realSamples.count < self.fftSize || self.imagSamples.count < self.fftSize {
            return samples
        }
        
        var real = self.realSamples.pop(self.fftSize)
        var imag = self.imagSamples.pop(self.fftSize)
        
        self.fftWindow.process(data: <#T##UnsafeMutablePointer<Float>#>)
        
        // create DSPSPlitComplex for FFT
        var inSamples:  DSPSplitComplex = DSPSplitComplex(realp: &real, imagp: &imag)
        
        // multiply samples by hann window
        vDSP_vmul(inSamples.realp, vDSP_Stride(1), &self.hannWindow, vDSP_Stride(1), inSamples.realp, vDSP_Stride(1), vDSP_Length(self.fftSize))
        vDSP_vmul(inSamples.imagp, vDSP_Stride(1), &self.hannWindow, vDSP_Stride(1), inSamples.imagp, vDSP_Stride(1), vDSP_Length(self.fftSize))
        
        // perform the fft
        // TODO: use vDSP_DFT_Execute as described in docs
        vDSP_fft_zip(self.fftSetup, &inSamples, vDSP_Stride(1), vDSP_Length(log2(Float(self.fftSize))), FFTDirection(kFFTDirection_Forward))
        
        // normalize fft results ?????
        var normalizeReal: Float = 1.0/Float32(self.fftSize)
        var normalizeImag: Float = 1.0/Float32(self.fftSize)
        var normalizeComplex = DSPSplitComplex(realp: &normalizeReal, imagp: &normalizeImag)
        vDSP_zvzsml(&inSamples, vDSP_Stride(1), &normalizeComplex, &inSamples, vDSP_Stride(1), vDSP_Length(self.fftSize))
        
        // get magnitudes
        var magnitudes = [Float](repeating: 0.0, count: self.fftSize)
        vDSP_zvmags(&inSamples, 1, &magnitudes, 1, vDSP_Length(self.fftSize))
        
        
        // https://developer.apple.com/library/content/samplecode/aurioTouch/Listings/Classes_FFTHelper_cpp.html
        // In order to avoid taking log10 of zero, an adjusting factor is added in to make the minimum value equal -128dB
        var minDB: Float32 = 1.5849e-13
        //        var minDB: Float32 = 0.0000000001  // min value equeal to -100dBFS
        let inMagnitudes = magnitudes
        vDSP_vsadd(inMagnitudes, 1, &minDB, &magnitudes, 1, vDSP_Length(self.fftSize))
        
        // convert to dbFS
        var dbScale: Float32 = 1
        var dbs        = [Float](repeating: 0.0, count: self.fftSize)
        vDSP_vdbcon(&magnitudes, 1, &dbScale, &dbs, 1, vDSP_Length(self.fftSize), 0)
        
        // re-arrange values to match -n/2 <-> n/2
        let halfPoint = dbs.count / 2
        for i in 0..<halfPoint {
            let temp             = dbs[i]
            dbs[i]               = dbs[i + halfPoint]
            dbs[i + halfPoint]   = temp
        }
        
        // post fft message with samples
        
        fftData?(dbs)
//        fftData?(dbs)
        
//        if let queue = self.notifyQueue {
//            queue.async {
                //                    let userInfo: [String : Any] = [fftSamplesUpdatedKey : dbs]
                //                    NotificationCenter.default.post(name: .fftSamplesUpdatedNotification, object: self, userInfo: userInfo)
//            }
//        }
        
        return samples
    }
}
