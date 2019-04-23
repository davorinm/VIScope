//
//  SpectrogramView.swift
//  ViScope
//
//  Created by Davorin Madaric on 23/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import AppKit
import SDR

class SpectrogramView: NSView {
    
    var data: [SDRSample] = [] {
        didSet {
            DispatchQueue.main.async {
                self.setNeedsDisplay(self.frame)
            }
            
        }
    }
    
    var context: CGContext? {
        return NSGraphicsContext.current?.cgContext
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Create sparkline path
        var sparkline = NSBezierPath()
        sparkline.lineWidth = 1
        
        // Add data points to path
        for (i, dat) in data.enumerated() {
            
            let xPos = CGFloat((dat.i + 1) / 2) * (dirtyRect.width )
            let yPos = CGFloat((dat.q + 1) / 2) * (dirtyRect.height )
            
            let point = CGPoint(x: xPos, y: yPos);
            
            if i == 0 { // starting point
                sparkline.move(to: point)
            } else {
                sparkline.line(to: point)
            }
        }
        
        // Draw sparkline
        NSColor.red.setStroke()
        sparkline.stroke()
    }
    
    
    
    
}
