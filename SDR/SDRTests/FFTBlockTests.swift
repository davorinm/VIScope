//
//  FFTBlockTests.swift
//  SDRTests
//
//  Created by Davorin Mađarić on 17/06/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import XCTest

class FFTBlockTests: XCTestCase {
    
//    override class var defaultPerformanceMetrics: [XCTPerformanceMetric] {
//        return []
//    }
    
    func testFFTBlock() {
        let sourceSamplesCount = 2^12
        let sourceSamples = DSP.ComplexSamples(capacity: sourceSamplesCount)
        sourceSamples.count = sourceSamplesCount
        
        let fft = FFTBlock(fftPoints: 2000)
        fft.fftData = { (samples) in
            
        }
        
        let processedSamples = fft.process(sourceSamples)
        
        wait(for: <#T##[XCTestExpectation]#>, timeout: <#T##TimeInterval#>)
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
