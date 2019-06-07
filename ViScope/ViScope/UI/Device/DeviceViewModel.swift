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
    private let close: (() -> Void)?
    
    init(device: SDRDevice, close: (() -> Void)?) {
        self.device = device
        self.close = close
    }
    
    func selectDevice() {
        SDR.selectDevice(device)
        close?()
    }
}

class DeviceViewModel {
    var updateItems: (() -> Void)?
    var close: (() -> Void)?

    private var devicesDisposable: Disposable?    
    private(set) var items: [DevicesItem] = []
    
    func load() {
        devicesDisposable = SDR.devices.subscribeWithRaise { [unowned self] (devices) in
            self.items = devices.map { DevicesItem(device: $0, close: self.close) }
            self.updateItems?()
        }
        
        updateItems?()
    }
}
