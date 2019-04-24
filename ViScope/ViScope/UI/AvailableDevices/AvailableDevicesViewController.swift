//
//  AvailableDevicesViewController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa
import SDR

class AvailableDevicesViewController: NSViewController {
    @IBOutlet private weak var popupButton: NSPopUpButton!    
    @IBOutlet private weak var selectionButton: NSButton!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SDR.availableDevicesNames.subscribeWithRaise(self) { [unowned self]  (devices) in
            self.popupButton.removeAllItems()
            self.popupButton.addItems(withTitles: devices)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func popupButtonAction(_ sender: Any) {
        print("popupButtonAction")
    }
    
    @IBAction func selectionButtonAction(_ sender: Any) {
        SDR.selectDevice(popupButton.indexOfSelectedItem)
    }
}
