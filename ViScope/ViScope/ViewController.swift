//
//  ViewController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 16/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    private let sdr: SoftwareDefinedRadio = SoftwareDefinedRadio()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

