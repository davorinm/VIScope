//
//  SoftwareDefinedRadio.swift
//  SDR
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

class SoftwareDefinedRadio {
    /// Singelton of shared SDR
    static let shared = SoftwareDefinedRadio()
    
    let devices: ObservableProperty<[String]> = ObservableProperty(value: [])
    let selectedDevices: ObservableProperty<[SDRDevice]> = ObservableProperty(value: [])
    let samples: ObservableEvent<SDRSamples> = ObservableEvent()
    
    var radio: Radio?
    
    private init() {
        USB.shared.registerEvents()
        
        devices.value = RTLSDR.deviceList().map { $0.name }
    }
    
    // MARK: - Devices
    
    func selectDevice(_ index: Int) {
        let device = RTLSDR.deviceList()[index]
        selectedDevices.value.append(contentsOf: device)
        
        radio = prepareChain()
        
        
        device.rawSamples.subscribe(self) { [unowned self] (samples) in
            self.radio?.samplesIn(samples)
        }
        
        device.startSampleStream()
    }
    
    func tunedFrequency(_ frequency: Int) {
        selectedDevice.value?.tunedFrequency(frequency: frequency)
    }
    
    func prepareChain() -> Radio {
        let normalize = NormalizeBlock(bits: 8)
        let fft = FFTBlock()
        
        let radio = Radio()
        radio.addBlock(normalize)
        radio.addBlock(fft)
        
        
    }
}
