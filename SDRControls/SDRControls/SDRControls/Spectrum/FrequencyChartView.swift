//
//  SpectrumView.swift
//  ViScope
//
//  Created by Davorin Madaric on 23/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation

public final class FrequencyChartView: UIView {
    public var min: Float!
    public var max: Float!
    
    private let axisLayer = CAShapeLayer()
    private let shapeLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    
    public override var frame: NSRect {
        didSet {
            print("Frame did change")
            layoutDidChange()
        }
    }
    
    public override var bounds: NSRect {
        didSet {
            print("Bounds did change")
            layoutDidChange()
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
        
        // Chart axis layer
        axisLayer.frame = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
        axisLayer.fillColor = NSColor.clear.cgColor
        axisLayer.strokeColor = NSColor.black.cgColor
        axisLayer.lineWidth = 1
        layer!.addSublayer(axisLayer)
        
        // Chart shape layer
        shapeLayer.frame = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
        shapeLayer.fillColor = NSColor.clear.cgColor
        shapeLayer.strokeColor = NSColor.black.cgColor
        shapeLayer.lineWidth = 1
        
        // Gradient mask layer
        gradientLayer.frame = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.colors = [NSColor.blue.cgColor, NSColor.green.cgColor, NSColor.red.cgColor]
        gradientLayer.mask = shapeLayer
        
        layer!.addSublayer(gradientLayer)
//        layer!.frame = frame
        layer!.anchorPoint = CGPoint(x: 0, y: 0)
        
        // TODO: Fix
        drawAxes()
    }
    
    // MARK: - Data
    
    public func setData(_ samples: [Float]) {
        // TODO: calculate min, max normalize data
        // TODO: Option to set custom min max, floor or ceil data, also for histogram
        
        
//        if samples.count != Int(shapeLayer.bounds.width) {
//            print("samples count missaligned \(samples.count - Int(shapeLayer.bounds.width))")
//        }
        
        if min == nil {
            min = samples.min()!
        }
        
        if max == nil {
            max = samples.max()!
        }
        
        let range = max - min
        let xScale = shapeLayer.frame.width / CGFloat(samples.count)
        
        let path = CGMutablePath()
        
        for (i, sample) in samples.enumerated() {
            
            let scaledValue = (sample - min) / range
            
            let point = CGPoint(x: xScale * CGFloat(i),
                                y: shapeLayer.frame.height * CGFloat(1 - scaledValue))
            
            if path.isEmpty {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        shapeLayer.path = path
    }
    
    // MARK: - Axis
    
    private var axesColor: UIColor = UIColor.gray.withAlphaComponent(0.3)
    private var gridColor: UIColor = UIColor.gray.withAlphaComponent(0.3)
    private var drawingHeight: CGFloat {
        get {
            return shapeLayer.frame.height
        }
    }
    private var drawingWidth: CGFloat {
        get {
            return shapeLayer.frame.width
        }
    }
    private var topInset: CGFloat = 20
    
    ///
    
    private func drawAxes() {
        drawAxesGrid()
//        drawLabelsAndGridOnXAxis()
//        drawLabelsAndGridOnYAxis()
    }
    
    private func drawAxesGrid() {
        let path = CGMutablePath()
        axisLayer.strokeColor = axesColor.cgColor
        axisLayer.lineWidth = 0.5
        
//        path.setStrokeColor(axesColor.cgColor)
//        path.setLineWidth(0.5)
        
        // horizontal axis at the bottom
        path.move(to: CGPoint(x: CGFloat(0), y: drawingHeight + topInset))
        path.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: drawingHeight + topInset))
        path.closeSubpath()
        
        // horizontal axis at the top
        path.move(to: CGPoint(x: CGFloat(0), y: CGFloat(0)))
        path.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: CGFloat(0)))
        path.closeSubpath()
        
        // horizontal axis when y = 0
//        if min.y < 0 && max.y > 0 {
//            let y = CGFloat(getZeroValueOnYAxis(zeroLevel: 0))
//            context.move(to: CGPoint(x: CGFloat(0), y: y))
//            context.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: y))
//            context.strokePath()
//        }
        
        // vertical axis on the left
        path.move(to: CGPoint(x: CGFloat(0), y: CGFloat(0)))
        path.addLine(to: CGPoint(x: CGFloat(0), y: drawingHeight + topInset))
        path.closeSubpath()
        
        // vertical axis on the right
        path.move(to: CGPoint(x: CGFloat(drawingWidth), y: CGFloat(0)))
        path.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: drawingHeight + topInset))
        path.closeSubpath()
        
        axisLayer.path = path
    }
    
//    private func drawLabelsAndGridOnXAxis() {
//        let context = UIGraphicsGetCurrentContext()!
//        context.setStrokeColor(gridColor.cgColor)
//        context.setLineWidth(0.5)
//
//        var labels: [Double]
//        if xLabels == nil {
//            // Use labels from the first series
//            labels = series[0].data.map({ (point: ChartPoint) -> Double in
//                return point.x })
//        } else {
//            labels = xLabels!
//        }
//
//        let scaled = scaleValuesOnXAxis(labels)
//        let padding: CGFloat = 5
//        scaled.enumerated().forEach { (i, value) in
//            let x = CGFloat(value)
//            let isLastLabel = x == drawingWidth
//
//            // Add vertical grid for each label, except axes on the left and right
//
//            if x != 0 && x != drawingWidth {
//                context.move(to: CGPoint(x: x, y: CGFloat(0)))
//                context.addLine(to: CGPoint(x: x, y: bounds.height))
//                context.strokePath()
//            }
//
//            if xLabelsSkipLast && isLastLabel {
//                // Do not add label at the most right position
//                return
//            }
//
//            // Add label
//            let label = UILabel(frame: CGRect(x: x, y: drawingHeight, width: 0, height: 0))
//            label.font = labelFont
//            label.text = xLabelsFormatter(i, labels[i])
//            label.textColor = labelColor
//
//            // Set label size
//            label.sizeToFit()
//            // Center label vertically
//            label.frame.origin.y += topInset
//            if xLabelsOrientation == .horizontal {
//                // Add left padding
//                label.frame.origin.y -= (label.frame.height - bottomInset) / 2
//                label.frame.origin.x += padding
//
//                // Set label's text alignment
//                label.frame.size.width = (drawingWidth / CGFloat(labels.count)) - padding * 2
//                label.textAlignment = xLabelsTextAlignment
//            } else {
//                label.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 3 / 2))
//
//                // Adjust vertical position according to the label's height
//                label.frame.origin.y += label.frame.size.height / 2
//
//                // Adjust horizontal position as the series line
//                label.frame.origin.x = x
//                if xLabelsTextAlignment == .center {
//                    // Align horizontally in series
//                    label.frame.origin.x += ((drawingWidth / CGFloat(labels.count)) / 2) - (label.frame.size.width / 2)
//                } else {
//                    // Give some space from the vertical line
//                    label.frame.origin.x += padding
//                }
//            }
//            self.addSubview(label)
//        }
//    }
//
//    private func drawLabelsAndGridOnYAxis() {
//        let context = UIGraphicsGetCurrentContext()!
//        context.setStrokeColor(gridColor.cgColor)
//        context.setLineWidth(0.5)
//
//        var labels: [Double]
//        if yLabels == nil {
//            labels = [(min.y + max.y) / 2, max.y]
//            if yLabelsOnRightSide || min.y != 0 {
//                labels.insert(min.y, at: 0)
//            }
//        } else {
//            labels = yLabels!
//        }
//
//        let scaled = scaleValuesOnYAxis(labels)
//        let padding: CGFloat = 5
//        let zero = CGFloat(getZeroValueOnYAxis(zeroLevel: 0))
//
//        scaled.enumerated().forEach { (i, value) in
//
//            let y = CGFloat(value)
//
//            // Add horizontal grid for each label, but not over axes
//            if y != drawingHeight + topInset && y != zero {
//
//                context.move(to: CGPoint(x: CGFloat(0), y: y))
//                context.addLine(to: CGPoint(x: self.bounds.width, y: y))
//                if labels[i] != 0 {
//                    // Horizontal grid for 0 is not dashed
//                    context.setLineDash(phase: CGFloat(0), lengths: [CGFloat(5)])
//                } else {
//                    context.setLineDash(phase: CGFloat(0), lengths: [])
//                }
//                context.strokePath()
//            }
//
//            let label = UILabel(frame: CGRect(x: padding, y: y, width: 0, height: 0))
//            label.font = labelFont
//            label.text = yLabelsFormatter(i, labels[i])
//            label.textColor = labelColor
//            label.sizeToFit()
//
//            if yLabelsOnRightSide {
//                label.frame.origin.x = drawingWidth
//                label.frame.origin.x -= label.frame.width + padding
//            }
//
//            // Labels should be placed above the horizontal grid
//            label.frame.origin.y -= label.frame.height
//
//            self.addSubview(label)
//        }
//        UIGraphicsEndImageContext()
//    }
    
    // MARK: - Layout
    
    private func layoutDidChange() {
    
        axisLayer.frame = bounds
        shapeLayer.frame = bounds
        gradientLayer.frame = bounds
        
        drawAxes()
    }
}
