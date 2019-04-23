//
//  TunerViewController.swift
//  ViScope
//
//  Created by Davorin Madaric on 18/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa
import SDR

class TunerViewController: NSViewController, NSComboBoxDelegate {
    @IBOutlet private weak var devicesComboBox: NSComboBox!
    @IBOutlet private weak var frequencyTextField: NSTextField!
    @IBOutlet private weak var frequencySlider: NSSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        devicesComboBox.delegate = self
        
        SDR.devices.subscribeWithRaise(self) { [unowned self]  (devices) in
            self.devicesComboBox.removeAllItems()
            self.devicesComboBox.addItems(withObjectValues: devices)
        }
        
        SDR.selectedDevice.subscribeWithRaise(self) { [unowned self]  (device) in
            guard let device = device else {
                return
            }
            
            self.frequencySlider.minValue = Double(device.minimumFrequency())
            self.frequencySlider.maxValue = Double(device.maximumFrequency())
            self.frequencySlider.doubleValue = Double(device.tunedFrequency())
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        
    }
    
    // MARK: - NSComboBoxDelegate
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if let comboBox = notification.object as? NSComboBox {
            SDR.selectDevice(comboBox.indexOfSelectedItem)
        }
    }
}
