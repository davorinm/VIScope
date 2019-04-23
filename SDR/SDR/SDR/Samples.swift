//
//  Samples.swift
//  waveSDR
//
//  Copyright © 2017 GetOffMyHack. All rights reserved.
//

import Foundation
import Accelerate

public struct Samples {
    
    enum SamplesType {
        case real
        case imaginary
        case complex
        case audio
    }
    
    var type:   SamplesType
    var real:   [Float]
    var imag:   [Float]
    var audio:  [Float]
    
    var count:  Int {
        
        switch self.type {
        
        case .audio:
            return self.audio.count
        case .imaginary:
            return self.imag.count
        default:
            return self.real.count
            
        }
        
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    init(realArray: [Float], imagArray: [Float], audio: [Float] = Array()) {
        
        self.type   = .complex
        self.real   = realArray
        self.imag   = imagArray
        self.audio  = audio

    }
}

//------------------------------------------------------------------------------
//
//
//
//------------------------------------------------------------------------------

extension Samples {
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    mutating func asDSPSplitComplex() -> DSPSplitComplex {
        
        // create and return a DSPSplitComplex type
        return DSPSplitComplex(realp: &real, imagp: &imag)
        
    }
}
