//
//  SDRSamples.swift
//  SDR
//
//  Created by Davorin Madaric on 23/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

public struct SDRSample {
    public let i: Double
    public let q: Double
}

public struct SDRSamples {
    private let samplesArray: [SDRSample]
    
    init?(normalizedSamples inSamples: [Double]) {
        samplesArray = stride(from: 0, to: inSamples.count, by: 2).map { SDRSample(i: inSamples[$0], q: inSamples[$0 + 1]) }
    }
    
    public func samples() -> [SDRSample] {
        return samplesArray
    }
}