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
    
    private let viewModel = DemodulatorViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
