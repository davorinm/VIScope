//
//  NSDraggingInfo+DraggedFileURL.swift
//  ViScope
//
//  Created by Davorin Mađarić on 08/05/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa

extension NSDraggingInfo {
    var draggedFileURL: NSURL? {
        let filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType.fileURL) as? [String]
        let path = filenames?.first
        
        return path.map(NSURL.init)
    }
}
