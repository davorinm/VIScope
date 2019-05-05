//
//  AvailableDevicesViewModel.swift
//  ViScope
//
//  Created by Davorin Mađarić on 26/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation
import SDR

enum DevicesViewMode: Int, CaseIterable {
    case available = 0
    case binded
}

class DevicesItem {
    private let device: SDRDevice
    
//    private var bindDevice: (() -> Void)?
    private(set) var binded: Bool = false
    
    init(device: SDRDevice) {
        self.device = device
    }
    
    func bindDevice() {
        SDR.bindDevice(device)
    }
}

class DevicesViewModel {
    var modeChanged: ((_ mode: DevicesViewMode) -> Void)?
    var updateItems: (() -> Void)?

    private var devicesDisposable: Disposable?    
    private var mode: DevicesViewMode!
    private(set) var items: [DevicesItem] = [] {
        didSet {
            updateItems?()
        }
    }
    
    func load() {
        // Initial mode setting
        setMode(.available)
    }
    
    func setMode(_ mode: DevicesViewMode) {
        switch mode {
        case .available:
            devicesDisposable = SDR.availableDevices.subscribeWithRaise { (devices) in
                self.items = devices.map { DevicesItem(device: $0) }
            }
        case .binded:
            devicesDisposable = SDR.bindedDevices.subscribeWithRaise { (devices) in
                self.items = devices.map { DevicesItem(device: $0) }
            }
        }
        
        modeChanged?(mode)
    }
}
