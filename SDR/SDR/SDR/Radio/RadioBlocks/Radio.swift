//
//  Radio.swift
//  SDR
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

class Radio {
    private let spectrumData: ObservableEvent<[Float]>
    private let processQueue: DispatchQueue = DispatchQueue(label: "Radio")
    
//    private var blocks: [RadioBlock] = []
//    private let radioPipeline: Future<SDRSamples>
    
    
    private var chain: (([UInt8]) -> SDRCplxSamples)?
    
    init(spectrumData: ObservableEvent<[Float]>) {
        self.spectrumData = spectrumData
        
        let normalize = NormalizeBlock(bits: 8)
        let split = SplitBlock()
        let fft = FFTBlock()
        fft.fftSize = 16000
        fft.fftData = { [unowned self] (samples) in
            
            let max = samples.max()!
            let min = samples.min()!
            
            let range = max - min
            
            
            let mappedSamples: [Float] = samples.enumerated().compactMap {
                // TODO: Make real interpolation of samples
                if $0.offset % 22 != 0 {
                    return nil
                }
                
                // Scaling 0...1
                let scaledValue = ($0.element - min) / range;
                return scaledValue
            }
            
            
            // Return on main thread
            DispatchQueue.main.async {
                self.spectrumData.raise(mappedSamples)
            }
        }
        let filter = ComplexFilterBlock(sampleRateIn: 2400000, sampleRateOut: 48000, cutoffFrequency: 5000, kernelLength: 300)
        
        // TODO: Stop using "-->" and use block chainig - linked list...
        chain = normalize.process --> fft.process --> filter.process
    }

    func samplesIn(_ rawSamples: [UInt8]) {
        processQueue.async { [unowned self] in
            self.chain?(rawSamples)
            
            
//            self.radioPipeline.perform(SDRSamples.raw(rawSamples), { (promise) in
//                switch promise {
//                case .success(_):
//                    break
//                case .failure(_):
//                    break
//                }
//            })
        }
    }
}



