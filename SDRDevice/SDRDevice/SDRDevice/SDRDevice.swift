//
//  SDRDevice.swift
//  waveSDR
//
//  Copyright © 2017 GetOffMyHack. All rights reserved.
//

import Foundation

public protocol SDRDeviceDelegate {
    func sdrDevice(_ device: SDRDevice, rawSamples: [UInt8])
//    func sdrDevice(_ device: SDRDevice, normalizedSamples: [Float])
}
public protocol SDRDevice: class {
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

public class SDRDevices {
    public class func deviceList() -> [SDRDevice] {
        return RTLSDR.deviceList()
    }
}
