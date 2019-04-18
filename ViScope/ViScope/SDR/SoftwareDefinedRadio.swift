//
//  SoftwareDefinedRadio.swift
//  ViScope
//
//  Created by Davorin Madaric on 18/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation
import SDRDevice

class SoftwareDefinedRadio {
    static let shared = SoftwareDefinedRadio()
    
    
    var deviceList: [SDRDevice] = []
    
    let fft: ObservableEvent<[Double]> = ObservableEvent<[Double]>()

    
    
    private init() {
        
        SDRDevices.deviceList()
        
        
    }
}
