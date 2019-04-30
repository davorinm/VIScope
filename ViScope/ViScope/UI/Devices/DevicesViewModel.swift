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

class DevicesViewModel {
    var modeChanged: ((_ mode: DevicesViewMode) -> Void)?
    var updateItems: (() -> Void)?

    private var devicesDisposable: Disposable?    
    private var mode: DevicesViewMode!
    private(set) var items: [SDRDevice] = [] {
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
                self.items = devices
            }
        case .binded:
            devicesDisposable = SDR.bindedDevices.subscribeWithRaise { (devices) in
                self.items = devices
            }
        }
        
        modeChanged?(mode)
    }
}
