//
//  AvailableDevicesViewModel.swift
//  ViScope
//
//  Created by Davorin Mađarić on 26/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation
import SDR

class DevicesViewModel {
    var updateItems: ((_ items: [String]) -> Void)?
    
    private var items: [String] = [] {
        didSet {
            updateItems?(items)
        }
    }
    
    init() {
        SDR.availableDevices.subscribeWithRaise(self) { [unowned self]  (devices) in
            if self.items == devices {
                print("Devices array are same")
                return
            }
            
            self.items = devices
        }
    }
    
    func load() {
        updateItems?(items)
    }
    
    func selectItem(_ index: Int) {
        SDR.bindDevice(index)
    }
}
