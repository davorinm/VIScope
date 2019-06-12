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
    @IBOutlet private weak var startStopButton: NSButton!
    @IBOutlet private weak var frequencyTextField: NSTextField!
    @IBOutlet private weak var frequencySlider: NSSlider!
    @IBOutlet private weak var frequencyStepper: NSStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.frequencyStepper.increment = 100000
        
        
        SDR.selectedDevice.subscribeWithRaise(self) { [unowned self]  (device) in
            guard let device = device else {
                return
            }
            
            self.frequencySlider.minValue = Double(device.minimumFrequency)
            self.frequencySlider.maxValue = Double(device.maximumFrequency)
            self.frequencySlider.doubleValue = Double(device.tunedFrequency)
            
            self.frequencyTextField.stringValue = device.tunedFrequency.description
            
            
            self.frequencyStepper.minValue = Double(device.minimumFrequency)
            self.frequencyStepper.maxValue = Double(device.maximumFrequency)
            self.frequencyStepper.doubleValue = Double(device.tunedFrequency)
            
            
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
        
    }
    
    // MARK: - Actions
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        SDR.selectedDevice.value?.tunedFrequency = Int(frequencySlider.doubleValue)
    }
    
    @IBAction func startStopButtonPressed(_ sender: Any) {
        
        if SDR.selectedDevice.value?.isOpen ?? false {
            SDR.stopDevice()
        } else {
            SDR.startDevice()
        }
        
        // TODO: Toggle device
        
        
    }
    
    @IBAction func frequencyStepperChanged(_ sender: Any) {
        self.frequencySlider.doubleValue = self.frequencyStepper.doubleValue
        SDR.selectedDevice.value?.tunedFrequency = Int(frequencyStepper.doubleValue)
    }
}
