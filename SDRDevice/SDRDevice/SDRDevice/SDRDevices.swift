//
//  SDRDevices.swift
//  SDRDevice
//
//  Created by Davorin Madaric on 18/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation

public class SDRDevices {
    public class func deviceList() -> [SDRDevice] {
        return RTLSDR.deviceList()
    }
}
