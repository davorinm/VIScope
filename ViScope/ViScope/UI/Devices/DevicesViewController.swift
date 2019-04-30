//
//  DevicesViewController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa

class DevicesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet private weak var modeSelectorControl: NSSegmentedControl!
    @IBOutlet private weak var tableView: NSTableView!
    
    private let viewModel = DevicesViewModel()
    
    private let availableDeviceCell = NSUserInterfaceItemIdentifier("availableDevice")
    private let bindedDeviceCell = NSUserInterfaceItemIdentifier("bindedDevice")
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modeSelectorControl.segmentCount = DevicesViewMode.allCases.count
        for (i, mode) in DevicesViewMode.allCases.enumerated() {
            switch mode {
            case .available:
                modeSelectorControl.setLabel("Available", forSegment: i)
            case .binded:
                modeSelectorControl.setLabel("Binded", forSegment: i)
            }
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NSNib(nibNamed: "AvailableDeviceCell", bundle: nil), forIdentifier: availableDeviceCell)
        tableView.register(NSNib(nibNamed: "BindedDeviceCell", bundle: nil), forIdentifier: bindedDeviceCell)
        
        viewModel.modeChanged = { [unowned self] (mode) in
            self.modeSelectorControl.selectedSegment = mode.rawValue
        }
        viewModel.updateItems = { [unowned self] in
            self.tableView.reloadData()
        }
        viewModel.load()
    }
    
    // MARK: - Actions
    
    @IBAction func modeSelectorChanged(_ sender: Any) {
        guard let mode = DevicesViewMode(rawValue: modeSelectorControl.selectedSegment) else {
            print("DevicesViewMode error")
            return
        }
        
        viewModel.setMode(mode)
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let count = viewModel.items.count
        print(count)
        return count
    }
    
//    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        let item = viewModel.items[row]
//        return item
//    }

    func tableView(tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return nil
    }

    
    // MARK: - NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = viewModel.items[row]
        
        if item.isOpen() {
            if let cell = tableView.makeView(withIdentifier: bindedDeviceCell, owner: nil) as? BindedDeviceCell {
                cell.setup(item)
                return cell
            }
        } else {
            if let cell = tableView.makeView(withIdentifier: availableDeviceCell, owner: nil) as? AvailableDeviceCell {
                cell.setup(item)
                return cell
            }
        }
        
        return nil
    }
}
