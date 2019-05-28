//
//  DemodulatorViewModel.swift
//  ViScope
//
//  Created by Davorin Mađarić on 26/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation
import SDR

class DemodulatorViewModel {
    var updateItems: (() -> Void)?
    
    private var items: [SDRDevice] = [] {
        didSet {
            updateItems?()
        }
    }
    
    init() {
        
    }
    
    func load() {
        updateItems?()
    }
    
    // MARK: - Table data
    
    func numberOfItems() -> Int {
        return items.count
    }
    
    func itemAt(index: Int) -> SDRDevice {
        return items[index]
    }
}
