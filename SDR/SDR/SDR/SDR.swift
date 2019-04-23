//
//  SDR.swift
//  ViScope
//
//  Created by Davorin Madaric on 18/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation

public class SDR {
    
    /// SDR devices list
    public class func devicesList() -> [SDRDevice] {
        return SDRDevices.devicesList()
    }
    
    public class func registerUsbEvents() {
        SDRDevices.registerUsbEvents()
    }
    
    
    var deviceList: [SDRDevice] = []
    
//    let fft: ObservableEvent<[Double]> = ObservableEvent<[Double]>()

    
    
    private init() {
        
//        SDRDevices.deviceList()
        
        
    }
}
