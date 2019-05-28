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
    private var chain: (([UInt8]) -> DSP.Samples)?
    
    init() {
        
        let normalize = NormalizeBlock(bits: 8)
        let split = SplitBlock()
        let fft = FFTBlock()
        fft.fftData = fftData
        let filter = ComplexFilterBlock(sampleRateIn: 2400000, sampleRateOut: 48000, cutoffFrequency: 5000, kernelLength: 300)
        
        
        spectrum.width.subscribe(self) { (width) in
            fft.interpolatedWidth = width
        }
        
        // TODO: Stop using "-->" and use block chainig - linked list...
        chain = normalize.process --> split.process --> fft.process
    }

    func samplesIn(_ rawSamples: [UInt8]) {
        processQueue.async { [unowned self] in
            _ = self.chain?(rawSamples)
        }
    }
    
    private func fftData(data: [Float]) {
        let max = data.max()!
        let min = data.min()!
        let range = max - min
        
        let mappedSamples: [Float] = data.enumerated().compactMap {
            // Scaling 0...1
            let scaledValue = ($0.element - min) / range;
            return scaledValue
        }
        
        // Return on main thread
        DispatchQueue.main.async {
            self.spectrum.data.raise(mappedSamples)
        }
    }
}
