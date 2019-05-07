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
    
    
    private var chain: (([UInt8]) -> [Float])?
    
    init(spectrumData: ObservableEvent<[Float]>) {
        self.spectrumData = spectrumData
        
        let normalize = NormalizeBlock(bits: 8)
        let fft = FFTBlock()
        fft.fftSize = 16000
        fft.fftData = { [unowned self] (data) in
            self.spectrumData.raise(data)
        }
        
        chain = normalize.process --> fft.process        
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



