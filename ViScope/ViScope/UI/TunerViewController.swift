//
//  TunerViewController.swift
//  ViScope
//
//  Created by Davorin Madaric on 18/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa
import SDRDevice

class TunerViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        SDRDevices.registerUsbEvents()
        
        // NSComboBox
        // https://www.raywenderlich.com/759-macos-controls-tutorial-part-1-2
    }
}
