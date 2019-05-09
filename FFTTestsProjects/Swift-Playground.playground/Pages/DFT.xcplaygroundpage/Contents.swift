//: [Previous](@previous)
//  https://developer.apple.com/library/ios/documentation/Performance/Conceptual/vDSP_Programming_Guide/USingDFTFunctions/USingDFTFunctions.html#//apple_ref/doc/uid/TP40005147-CH4-SW1

import Foundation
import Accelerate
import XCPlayground

// Playground Helper
func plot<T>(values: [T], title: String) {
    for value in values {
        XCPlaygroundPage.currentPage.captureValue(value, withIdentifier: title)
    }
}

func plot(real: [Float], imaginary: [Float], title: String) {
    for (index, r) in real.enumerate() {
        let i = imaginary[index]
        XCPlaygroundPage.currentPage.captureValue(r*r+i*i, withIdentifier: title)
    }
}

// Time Domain to Freqency Domain
let real:[Float] = [1.0, 2.0, 1.0, 2.0]

plot(real, title: "Time Domain")
let imaginary = [Float](count:real.count, repeatedValue: 0.0)

var real_frequency = [Float](count:real.count, repeatedValue: 0.0)
var imaginary_frequency = [Float](count:real.count, repeatedValue: 0.0)

let length = vDSP_Length(real.count)


let forward = vDSP_DFT_zop_CreateSetup(nil, length, vDSP_DFT_Direction.FORWARD)

vDSP_DFT_Execute(forward, real, imaginary, &real_frequency, &imaginary_frequency)

plot(real_frequency, imaginary:imaginary_frequency, title: "Frequency Domain")

vDSP_DFT_DestroySetup(forward)

// Frequency Domain to Time Domain

let inverse = vDSP_DFT_zop_CreateSetup(nil, length, vDSP_DFT_Direction.INVERSE)

var real_time = [Float](count:real.count, repeatedValue: 0.0)
var imaginary_time = [Float](count:real.count, repeatedValue: 0.0)

vDSP_DFT_Execute(inverse, real_frequency, imaginary_frequency, &real_time, &imaginary_time)

plot(real_time, imaginary:imaginary_time, title: "Back to Time Domain")

vDSP_DFT_DestroySetup(inverse)
