//
//  SDRDevice.swift
//  waveSDR
//
//  Copyright © 2017 GetOffMyHack. All rights reserved.
//

import Foundation

//------------------------------------------------------------------------------
//
// This module describes the API for a generic SDR hardware device
//
// All SDR device modules must follow the protocol and override the class
// methods, making the SDRDevice class nothing but an abstract
//
//------------------------------------------------------------------------------

protocol SDRDeviceDelegate {
    func sdrDevice(_ device: SDRDevice, rawSamples: [UInt8])
//    func sdrDevice(_ device: SDRDevice, normalizedSamples: [Float])
}

//------------------------------------------------------------------------------
//
//
//
//------------------------------------------------------------------------------

protocol SDRDevice: class {
    var delegate: SDRDeviceDelegate? { get set }
    
    func minimumFrequency() -> Int
    func maximumFrequency() -> Int

    func sampleRate() -> Int
    func sampleRate(rate: Int)
    func sampleRateList() -> [Int]
    
    func tunedFrequency() -> Int
    func tunedFrequency(frequency: Int)
    
    func frequencyCorrection() -> Int
    func frequencyCorrection(correction: Int)
    
    func tunerGainArray() -> [Int]
    func tunerAutoGain() -> Bool
    func tunerAutoGain(auto: Bool)
    func tunerGain() -> Int
    func tunerGain(gain: Int)
    
    func isOpen() -> Bool
    func isConfigured() -> Bool
    
    func startSampleStream()
    func stopSampleStream()
    
}
