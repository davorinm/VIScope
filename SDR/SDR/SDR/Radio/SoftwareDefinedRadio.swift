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
    
    let availableDevices: ObservableProperty<[String]> = ObservableProperty(value: [])
    let bindedDevices: ObservableProperty<[SDRDevice]> = ObservableProperty(value: [])
    let samples: ObservableEvent<SDRSamples> = ObservableEvent()
    
    var radio: Radio?
    
    private init() {
        
        radio = prepareChain()
        
        
        
        USB.shared.registerEvents()
        
        availableDevices.value = RTLSDR.deviceList().map { $0.name }
    }
    
    // MARK: - Devices
    
    func bindDevice(_ index: Int) {
        let device = RTLSDR.deviceList()[index]
        bindedDevices.value.append(device)
        
        
        device.rawSamples.subscribe(self) { [unowned self] (samples) in
            self.radio?.samplesIn(samples)
        }
        
        device.startSampleStream()
    }
    
    func prepareChain() -> Radio {
        let normalize = NormalizeBlock(bits: 8)
        let fft = FFTBlock()
        
        let radio = Radio()
        radio.addBlock(normalize)
        radio.addBlock(fft)
        
        return radio
    }
}
