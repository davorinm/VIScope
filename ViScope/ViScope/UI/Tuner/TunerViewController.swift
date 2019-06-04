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
    @IBOutlet private weak var frequencyTextField: NSTextField!
    @IBOutlet private weak var frequencySlider: NSSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
//        SDR.selectedDevices.subscribeWithRaise(self) { [unowned self]  (device) in
//            guard let device = device else {
//                return
//            }
//            
//            self.frequencySlider.minValue = Double(device.minimumFrequency())
//            self.frequencySlider.maxValue = Double(device.maximumFrequency())
//            self.frequencySlider.doubleValue = Double(device.tunedFrequency())
//        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // 1
        guard let window = view.window else {
            print("NO WINDOW!!")
            return
        }
        
        // 2
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        // 3
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                // 4
                let selected = panel.urls[0]
                
                
                SDR.startFileSampleStream(selected)
            }
        }
    }
}
