//
//  SoftwareDefinedRadio.swift
//  SDR
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

https://github.com/FutureKit/FutureKit/blob/master/FutureKit/FutureFIFO.swift

https://albertodebortoli.com/2018/02/12/the-easiest-promises-in-swift/
https://github.com/mxcl/PromiseKit

class StuffMaker {
    func iBuildStuffWithFutures() -> Future<NSData> {
        let p = Promise<NSData>()
        dispatch_async(self.mycustomqueue)  {
            // do stuff to make your NSData
            if (SUCCESS) {
                let goodStuff = NSData()
                p.completeWithSuccess(goodStuff)
            }
            else {
                p.completeWithFail(NSError())
            }
        }
        return p.future()
    }
}

class SoftwareDefinedRadio {
    /// Singelton of shared SoftwareDefinedRadio
    static let shared = SoftwareDefinedRadio()
    
    let availableDevices: ObservableProperty<[SDRDevice]> = ObservableProperty(value: [])
    let bindedDevices: ObservableProperty<[SDRDevice]> = ObservableProperty(value: [])
    let spectrumData: ObservableEvent<SDRSamples> = ObservableEvent()
    
    private var devices: [SDRDevice] = []
    private var radio: Radio?
    
    private init() {
        devices = RTLSDR.deviceList()
        radio = prepareChain()
        
        USB.shared.onChange = { [unowned self] in
            self.devices = RTLSDR.deviceList()
        }
        
        availableDevices.value = devices
        
        
        
        
        let ttt = FutureChain.create().then { (Int) -> Future<Int> in
            
            return Future { _ in
                
            }
            
            }.then { (val: Int) -> Future<Double> in
                return 5.5
        }
        
        
        
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
