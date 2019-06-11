//
//  Radio.swift
//  SDR
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

class Radio {
    private let processQueue: DispatchQueue = DispatchQueue(label: "Radio")
    
    let spectrum = SDRSpectrum()
    let ifSpectrum = SDRSpectrum()
    
    private var chain: (([Float]) -> (DSP.ComplexSamples))?
    
    // TODO: Create array of radio blocks
    let split: SplitBlock
    let fft: FFTBlock
    
    init() {
        let inputSampleRate: Int = 2400000
        let audioSampleRate = 48000
        let localOscillator = 1000000

        split = SplitBlock()
        fft = FFTBlock(fftPoints: 2000)
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
    
    private func fftData(data: [Float]) {
        // Return on main thread
        DispatchQueue.main.async {
            self.spectrum.data.raise(data)
        }
    }
    
    private func ifFftData(data: [Float]) {
        // Return on main thread
        DispatchQueue.main.async {
            self.ifSpectrum.data.raise(data)
        }
    }
}
