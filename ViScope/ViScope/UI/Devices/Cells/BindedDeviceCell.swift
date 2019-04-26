//
//  BindedDeviceCell.swift
//  ViScope
//
//  Created by Davorin Mađarić on 26/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa
import SDR

class BindedDeviceCell: NSTableCellView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("awakeFromNib")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        print("prepareForReuse")
    }

    func setup(_ item: SDRDevice) {
        
        print("setup item SDRDevice")
        
        
    }
    
}
