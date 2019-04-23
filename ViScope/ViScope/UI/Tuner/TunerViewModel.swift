//
//  TunerViewModel.swift
//  ViScope
//
//  Created by Davorin Madaric on 21/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation
import SDR

class TunerViewModel {
    
    func load() {
        
        
        
        
    }
    
    // MARK: - Devices
    
    func numberOfDevices() -> Int {
        return SDR.devicesList().count
    }
    
    func deviceAt(_ index: Int) -> SDRDevice {
        return SDR.devicesList()[index]
    }
    
    func deviceSelected(_ index: Int) {
        let device = SDR.devicesList()[index]
        device.tunedFrequency(frequency: 102800000)
        device.rawSamples = { [unowned self] (device, samples) in
            print(samples)
        }
        device.startSampleStream()
    }
}
