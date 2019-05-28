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
                
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NSNib(nibNamed: "AvailableDeviceCell", bundle: nil), forIdentifier: availableDeviceCell)
        tableView.register(NSNib(nibNamed: "BindedDeviceCell", bundle: nil), forIdentifier: bindedDeviceCell)
        
        viewModel.updateItems = { [unowned self] in
            self.tableView.reloadData()
        }
        viewModel.load()
    }
    
    // MARK: - Actions
    
    
    
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
        
        if item.binded {
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
