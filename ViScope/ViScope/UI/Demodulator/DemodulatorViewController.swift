//
//  DemodulatorViewController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa

class DemodulatorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet private weak var tableView: NSTableView!
    
    private let viewModel = BindedDevicesViewModel()
    
    private let bindedDeviceCell = NSUserInterfaceItemIdentifier("bindedDevice")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(NSNib(nibNamed: "BindedDeviceCell", bundle: nil), forIdentifier: bindedDeviceCell)
        
        viewModel.updateItems = { [unowned self] in
            self.tableView.reloadData()
        }
        viewModel.load()
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: bindedDeviceCell, owner: nil) as? BindedDeviceCell else {
            return nil
        }
        
        let item = viewModel.itemAt(index: row)
        cell.setup(item)
        
        return cell
    }
}
