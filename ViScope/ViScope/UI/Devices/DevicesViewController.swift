//
//  DevicesViewController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa

class DevicesViewController: NSViewController {
    @IBOutlet private weak var popupButton: NSPopUpButton!    
    @IBOutlet private weak var selectionButton: NSButton!
    
    private let viewModel = DevicesViewModel()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.updateItems = { [unowned self] (items) in            
            self.popupButton.removeAllItems()
            self.popupButton.addItems(withTitles: items)
            self.popupButton.selectItem(at: 0)
        }
        viewModel.updateSelect = { [unowned self] (bind, enabled) in
            switch bind {
            case .bind:
                self.selectionButton.title = "Bind device"
            case .unbind:
                self.selectionButton.title = "Unbind device"
            }
            
            self.selectionButton.isEnabled = enabled
        }
        viewModel.load()
    }
    
    // MARK: - Actions
    
    @IBAction func popupButtonAction(_ sender: Any) {
        print("popupButtonAction")
    }
    
    @IBAction func selectionButtonAction(_ sender: Any) {
        viewModel.selectItem(popupButton.indexOfSelectedItem)
    }
}
