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
//class StuffMaker {
//    func iBuildStuffWithFutures() -> Future<NSData> {
//        let p = Promise<NSData>()
//        dispatch_async(self.mycustomqueue)  {
//            // do stuff to make your NSData
//            if (SUCCESS) {
//                let goodStuff = NSData()
//                p.completeWithSuccess(goodStuff)
//            }
//            else {
//                p.completeWithFail(NSError())
//            }
//        }
//        return p.future()
//    }
//}

class SoftwareDefinedRadio {
    static let shared = SoftwareDefinedRadio()
    
    let devices: ObservableProperty<[SDRDevice]> = ObservableProperty(value: [])
    let spectrum: SDRSpectrum
    
    private let radio: Radio
    
    private init() {
        self.radio = Radio()
        self.spectrum = self.radio.spectrum

        
        
        
        
        
        self.updateDevices()
        
        USB.shared.onChange = { [unowned self] in
            self.updateDevices()
        }
        
        
        
        // Play a bell sound:
        //FMSynthesizer.shared.play(carrierFrequency: 440.0, modulatorFrequency: 679.0, modulatorAmplitude: 0.8)
    }
    
    // MARK: -
    
    private func updateDevices() {
        devices.value = RTLSDR.deviceList() + [NoiseSDRDevice()]
    }
    
    // MARK: - Devices
    
    func createDevice(_ devices: [SDRDevice]) {
        // TODO: IMp
    }
    
    func bindDevice(_ device: SDRDevice) {
        // TODO: Fix
//        bindedDevices.value.append(device)

        device.rawSamples.subscribe(self) { [unowned self] (samples) in
            self.radio.samplesIn(samples)
        }
        
        device.startSampleStream()
    }
}
