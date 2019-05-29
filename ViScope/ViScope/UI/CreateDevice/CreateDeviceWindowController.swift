//
//  CreateDeviceWindowController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 28/05/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa

class CreateDeviceWindowController: NSWindowController, NSWindowDelegate {
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.delegate = self
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
    }
    
    func windowDidMiniaturize(_ notification: Notification) {
        print("Window minimized")
    }
    
    func windowWillClose(_ notification: Notification) {
        print("Window closing")
    }
    
    
}
