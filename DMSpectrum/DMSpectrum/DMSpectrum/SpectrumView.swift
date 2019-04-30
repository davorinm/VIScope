//
//  SpectrumView.swift
//  ViScope
//
//  Created by Davorin Madaric on 23/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa

public final class SpectrumView: NSView {
    private var data: [Double] = []
    
    private var context: CGContext? {
        return NSGraphicsContext.current?.cgContext
    }
    
    public func setData(_ samples: [Double]) {
        data = samples
        
        DispatchQueue.main.async {
            self.setNeedsDisplay(self.bounds)
        }
    }
    
    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard data.count > 0 else {
            return
        }
        
        // Create sparkline path
        let bezierPath = NSBezierPath()
        bezierPath.lineWidth = 1
        
        let ttt = self.bounds.width / CGFloat(data.count)
        
        // Add data points to path
        for (i, dat) in data.enumerated() {
            
            let xPos = CGFloat(i) * ttt
            let yPos = CGFloat(dat) * (self.bounds.height )
            
            let point = CGPoint(x: xPos, y: yPos);
            
            if i == 0 { // starting point
                bezierPath.move(to: point)
            } else {
                bezierPath.line(to: point)
            }
        }
        
        // Draw sparkline
        NSColor.red.setStroke()
        bezierPath.stroke()
    }
}
