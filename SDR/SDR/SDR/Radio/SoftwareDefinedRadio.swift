//
//  SoftwareDefinedRadio.swift
//  SDR
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

//https://github.com/FutureKit/FutureKit/blob/master/FutureKit/FutureFIFO.swift
//
//https://albertodebortoli.com/2018/02/12/the-easiest-promises-in-swift/
//https://github.com/mxcl/PromiseKit
//

class SoftwareDefinedRadio {
    static let shared = SoftwareDefinedRadio()
    
    let devices: ObservableProperty<[SDRDevice]> = ObservableProperty(value: [])
    let selectedDevice: ObservableProperty<SDRDevice?> = ObservableProperty(value: nil)
    let spectrum: SDRSpectrum
    let ifSpectrum: SDRSpectrum
    
    private let radio: Radio
    private let testDevices: [SDRDevice] = [FileSDRDevice()]
    private var createdDevices: [SDRDevice] = []
    private var deviceSamplesDisposable: Disposable?
    
    private init() {
        self.radio = Radio()
        
        // TODO: Implement better spectrum passing
        self.spectrum = self.radio.spectrum
        self.ifSpectrum = self.radio.ifSpectrum

        
        
        
        
        
        self.updateDevices()
        
        USB.shared.onChange = { [unowned self] in
            self.updateDevices()
        }
        
        
        
        // Play a bell sound:
        //FMSynthesizer.shared.play(carrierFrequency: 440.0, modulatorFrequency: 679.0, modulatorAmplitude: 0.8)
    }
    
    // MARK: -
    
    private func updateDevices() {
        devices.value = RTLSDR.deviceList() + testDevices + createdDevices
    }
    
    // MARK: - Devices
    
    func createDevice(_ devices: [SDRDevice]) {
        // TODO: Implement
    }
    
    func selectDevice(_ device: SDRDevice) {
        self.deviceSamplesDisposable = nil
        self.selectedDevice.value = device
        
        guard let device = self.selectedDevice.value else {
            print("Device cannot be selected")
            return
        }
        
        deviceSamplesDisposable = device.samples.subscribe { [unowned self] (samples) in
            self.radio.samplesIn(samples)
        }
    }
    
    func startDevice() {
        guard let device = self.selectedDevice.value else {
            print("Device cannot be selected")
            return
        }
        
        device.startSampleStream()
    }
    
    func stopDevice() {
        guard let device = self.selectedDevice.value else {
            print("Device cannot be selected")
            return
        }
        
        device.stopSampleStream()
    }
}
