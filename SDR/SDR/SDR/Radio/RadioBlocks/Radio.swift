//
//  Radio.swift
//  SDR
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Accelerate

class Radio {
    private let processQueue: DispatchQueue = DispatchQueue(label: "Radio")
    
    let spectrum = SDRSpectrum()
    let ifSpectrum = SDRSpectrum()
    
    private var chain: (([Float]) -> (DSP.ComplexSamples))?
    
    // TODO: Create array of radio blocks
    let split: SplitBlock
    let fft: FFTBlock
    
    let fftPoints = 1024
    
    init() {
        let inputSampleRate: Int = 2400000
        let audioSampleRate = 48000
        let localOscillator = 1000000
        
        avgData = [Float](repeating: 0, count: fftPoints)

        split = SplitBlock()
        fft = FFTBlock(fftPoints: fftPoints)
        let complexMixer = ComplexMixerBlock(sampleRate: inputSampleRate, frequency: localOscillator)
        let ifFilter = ComplexFilterBlock(sampleRateIn: inputSampleRate, sampleRateOut: 600000, cutoffFrequency: 500000, kernelLength: 300)
//        let ifFft = FFTBlock(fftPoints: 6000)
        let fmDemodulator = FMDemodulatorBlock()
        let audioFilter = RealFilterBlock(sampleRateIn: 240000, sampleRateOut: audioSampleRate, cutoffFrequency: 15000, kernelLength: 300)
        let audioPlayer = AudioBlock()
        audioPlayer.startAudio()
        
        fft.fftData = fftData
        spectrum.width.subscribe(self) { (width) in
//            fft.interpolatedWidth = width
        }
        
//        ifFft.fftData = ifFftData
//        ifSpectrum.width.subscribe(self) { (width) in
//            ifFft.interpolatedWidth = width
//        }
        
        // TODO: Stop using "-->" and use block chainig - linked list...
        chain = split.process --> fft.process //--> complexMixer.process --> ifFilter.process --> ifFft.process --> fmDemodulator.process --> audioFilter.process --> audioPlayer.process
    }

    func samplesIn(_ rawSamples: [Float]) {
        processQueue.async { [unowned self] in
            _ = self.chain?(rawSamples)
        }
    }
    
    var avgData: [Float]
    var avgDataIndex = 0
    
    // TODO: Create block for averaging
    private func fftData(data: [Float]) {
        vDSP_vadd(data, 1, avgData, 1, &avgData, 1, vDSP_Length(fftPoints))
        avgDataIndex += 1
        
        if avgDataIndex >= 200 {
            var averageddata: [Float] = [Float](repeating: 0, count: fftPoints)
            var i: Float = Float(avgDataIndex)
            
            vDSP_vsdiv(avgData, 1, &i, &averageddata, 1, vDSP_Length(fftPoints))
            
            vDSP_vclr(&avgData, 1, vDSP_Length(fftPoints))
            avgDataIndex = 0
            
            // Return on main thread
            DispatchQueue.main.async {
                self.spectrum.data.raise(averageddata)
            }
        }
    }
    
    private func ifFftData(data: [Float]) {
        // Return on main thread
        DispatchQueue.main.async {
            self.ifSpectrum.data.raise(data)
        }
    }
}
