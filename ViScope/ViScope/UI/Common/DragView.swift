//
//  DragView.swift
//  ViScope
//
//  Created by Davorin Mađarić on 08/05/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa

protocol DragViewDelegate {
    var acceptedFileExtensions: [String] { get }
    func dragView(dragView: DragView, didDragFileWith URL: NSURL)
}

class DragView: NSView {
    var delegate: DragViewDelegate?
    
    private var fileTypeIsOk = false
    private var acceptedFileExtensions: [String] {
        return delegate?.acceptedFileExtensions ?? []
    }
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL, NSPasteboard.PasteboardType.URL])
    }
    
    // MARK: - Dragging
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(drag: sender) {
            fileTypeIsOk = true
            return .copy
        } else {
            fileTypeIsOk = false
            return []
        }
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if fileTypeIsOk {
            return .copy
        } else {
            return []
        }
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let draggedFileURL = sender.draggedFileURL else {
            return false
        }
        
        delegate?.dragView(dragView: self, didDragFileWith: draggedFileURL)
        
        return true
    }
    
    func checkExtension(drag: NSDraggingInfo) -> Bool {
        guard let fileExtension = drag.draggedFileURL?.pathExtension?.lowercased() else {
            return false
        }
        
        return acceptedFileExtensions.contains(fileExtension)
    }
}
