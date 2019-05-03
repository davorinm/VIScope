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
    private let gradientLayer = CAGradientLayer()
    
    public override var frame: NSRect {
        didSet {
            shapeLayer.frame = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
            gradientLayer.frame = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
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
        
        // Chart shape layer
        shapeLayer.frame = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
        shapeLayer.fillColor = NSColor.clear.cgColor
        shapeLayer.strokeColor = NSColor.black.cgColor
        shapeLayer.lineWidth = 1
        
        // Gradient mask layer
        gradientLayer.frame = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.colors = [NSColor.red.cgColor, NSColor.green.cgColor, NSColor.blue.cgColor]
        gradientLayer.mask = shapeLayer
        
        layer!.addSublayer(gradientLayer)
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
