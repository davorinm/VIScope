//
//  SpectrumView.swift
//  ViScope
//
//  Created by Davorin Madaric on 23/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa

public final class SpectrumView: NSView {
    private let shapeLayer = CAShapeLayer()
    
    public override var frame: NSRect {
        didSet {
            shapeLayer.frame = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
        }
    }
    
    // MARK: - Init
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setup()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        setup()
    }
    
    private func setup() {
        wantsLayer = true
        layer!.addSublayer(shapeLayer)
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = NSColor.red.cgColor
        shapeLayer.lineWidth = 1
    }
    
    // MARK: - Data
    
    public func setData(_ samples: [Double]) {
        let path = CGMutablePath()
        let xScale = shapeLayer.frame.width / CGFloat(samples.count)
        let points = samples.enumerated().map {
            return CGPoint(x: xScale * CGFloat($0.offset),
                           y: shapeLayer.frame.height * CGFloat(1.0 - ($0.element.isFinite ? $0.element : 0)))
        }
        
        path.addLines(between: points)
        shapeLayer.path = path
    }
}
