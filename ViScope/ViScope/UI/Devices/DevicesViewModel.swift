//
//  AvailableDevicesViewModel.swift
//  ViScope
//
//  Created by Davorin Mađarić on 26/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation
import SDR

class DevicesItem {
    let device: SDRDevice
    
    private(set) var binded: Bool = false
    
    init(device: SDRDevice) {
        self.device = device
    }
    
    func startDevice() {
        SDR.startDevice(device)
    }
}

class DevicesViewModel {
    var updateItems: (() -> Void)?

    private var devicesDisposable: Disposable?    
    private(set) var items: [DevicesItem] = [] {
        didSet {
            updateItems?()
        }
    }
    
    func load() {
        devicesDisposable = SDR.devices.subscribeWithRaise { (devices) in
            self.items = devices.map { DevicesItem(device: $0) }
        }
    }
}
