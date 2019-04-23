//
//  TunerViewController.swift
//  ViScope
//
//  Created by Davorin Madaric on 18/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa
import SDR

class TunerViewController: NSViewController, NSComboBoxDelegate, NSComboBoxDataSource {
    @IBOutlet private weak var devicesComboBox: NSComboBox!
    
    private let model = TunerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        devicesComboBox.delegate = self
        devicesComboBox.dataSource = self
        
        model.load()
        // Do view setup here.
        
        SDR.registerUsbEvents()
        
        // NSComboBox
        // https://www.raywenderlich.com/759-macos-controls-tutorial-part-1-2
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        devicesComboBox.removeAllItems()
        for device in SDR.devicesList() {
            
            
            
            devicesComboBox.addItem(withObjectValue: device.name)
        }
    }
    
    // MARK: - NSComboBoxDataSource
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return model.numberOfDevices()
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        let device = model.deviceAt(index)
        return device.name
    }
    
    // MARK: - NSComboBoxDelegate
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if let comboBox = notification.object as? NSComboBox {
            model.deviceSelected(comboBox.indexOfSelectedItem)
        }
    }
}
