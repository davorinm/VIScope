//
//  DeviceCell.swift
//  ViScope
//
//  Created by Davorin Mađarić on 26/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa

class DeviceCell: NSTableCellView {
    @IBOutlet private weak var deviceNameField: NSTextField!
    
    private var bindDevice: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("awakeFromNib")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        print("prepareForReuse")
        bindDevice = nil
    }
    
    func setup(_ item: DevicesItem) {
        deviceNameField.stringValue = item.device.name
        bindDevice = item.startDevice
    }
    
    // MARK: - Actions
    
    @IBAction func bindButtonPressed(_ sender: Any) {
        bindDevice?()
    }
}
