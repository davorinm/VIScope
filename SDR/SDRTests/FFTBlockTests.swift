//
//  FFTBlockTests.swift
//  SDRTests
//
//  Created by Davorin Mađarić on 17/06/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import XCTest

class FFTBlockTests: XCTestCase {
    
    func testFFTBlock() {
        let ttt = XCTestExpectation(description: "T")
        
        let sourceSamplesCount = 34000
        let sourceSamples = DSP.ComplexSamples(capacity: sourceSamplesCount)
        sourceSamples.count = sourceSamplesCount
        
        let fft = FFTBlock(fftPoints: 2000)
        fft.fftData = { (samples) in
            ttt.fulfill()
        }
        
        let processedSamples = fft.process(sourceSamples)
        
        wait(for: [ttt], timeout: 5)
    }
    
    func testFFTBlockPerformance() {
        self.measure {
            for _ in 1..<100 {
                print("wasting time")
            }
            let _ = malloc(3000)
        }
    }
}
