//
//  MainViewController.swift
//  ViScope
//
//  Created by Davorin Madaric on 07/06/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import AppKit
import SDR

class MainViewController: NSViewController {

    @IBAction func openDevice(_ sender: Any) {
        let storyboard = NSStoryboard(name: "Device", bundle: nil)
        let vc = storyboard.instantiateController(withIdentifier: "DeviceViewController") as! DeviceViewController
        
        //        NSApplication.shared.runModal(for: windowController.window!)
        //        self.presentAsSheet(vc)
        
        self.presentAsModalWindow(vc)
    }
    
    @IBAction func openFile(_ sender: Any) {
        guard let window = view.window else {
            print("NO WINDOW!!")
            return
        }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                let selectedUrl = panel.urls[0]
                SDR.startFileSampleStream(selectedUrl)
            }
        }
    }
}
