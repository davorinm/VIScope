//
//  Platform.swift
//  DMSpectrum
//
//  Created by Davorin Madaric on 02/06/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit



#endif

#if os(OSX)
import AppKit

public typealias UIFont = NSFont
public typealias UIColor = NSColor
public typealias UIEvent = NSEvent
public typealias UITouch = NSTouch
public typealias UIImage = NSImage
//public typealias UIControl = NSControl
//
open class UILabel: NSTextField {
    
    open var text: String? {
        get {
            return self.stringValue
        }
        set {
            self.stringValue = text ?? ""
        }
    }
    
    open var textAlignment: NSTextAlignment {
        get {
            return self.alignment
        }
        set {
            self.alignment = textAlignment
        }
    }
    
    open var transform: CGAffineTransform {
        get {
            return self.layer?.affineTransform() ?? CGAffineTransform()
        }
        set {
            self.wantsLayer = true
            self.layer?.setAffineTransform(transform)
        }
    }
}
//
//extension NSView {
//

//
//    open var contentMode: Any {
//        get {
//            return 2
//        }
//        set {
//
//        }
//    }
//
//
////    open var uiLayer: CALayer {
////        get {
////            return self.layer ?? CALayer(layer: <#T##Any#>)
////        }
////    }
//}
//
open class UIView: NSView
{
    /// A private constant to set the accessibility role during initialization.
    /// It ensures parity with the iOS element ordering as well as numbered counts of chart components.
    /// (See Platform+Accessibility for details)
    private let role: NSAccessibility.Role = .list
    
    public override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        setAccessibilityRole(role)
    }
    
    required public init?(coder decoder: NSCoder)
    {
        super.init(coder: decoder)
        setAccessibilityRole(role)
    }
    
    public final override var isFlipped: Bool
    {
        return true
    }
    
    func setNeedsDisplay()
    {
        self.setNeedsDisplay(self.bounds)
    }
    
    open var backgroundColor: UIColor? {
        get
        {
            return self.layer?.backgroundColor == nil
                ? nil
                : NSColor(cgColor: self.layer!.backgroundColor!)
        }
        set
        {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue == nil ? nil : newValue!.cgColor
        }
    }
    
    public final override func touchesBegan(with event: NSEvent)
    {
        self.nsuiTouchesBegan(event.touches(matching: .any, in: self), withEvent: event)
    }
    
    public final override func touchesEnded(with event: NSEvent)
    {
        self.nsuiTouchesEnded(event.touches(matching: .any, in: self), withEvent: event)
    }
    
    public final override func touchesMoved(with event: NSEvent)
    {
        self.nsuiTouchesMoved(event.touches(matching: .any, in: self), withEvent: event)
    }
    
    open override func touchesCancelled(with event: NSEvent)
    {
        self.nsuiTouchesCancelled(event.touches(matching: .any, in: self), withEvent: event)
    }
    
    open func nsuiTouchesBegan(_ touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesBegan(with: event!)
    }
    
    open func nsuiTouchesMoved(_ touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesMoved(with: event!)
    }
    
    open func nsuiTouchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesEnded(with: event!)
    }
    
    open func nsuiTouchesCancelled(_ touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        super.touchesCancelled(with: event!)
    }
}

// MARK: - GraphicsContext

func UIGraphicsGetCurrentContext() -> CGContext?
{
    return NSGraphicsContext.current?.cgContext
}

func UIGraphicsPushContext(_ context: CGContext)
{
    let cx = NSGraphicsContext(cgContext: context, flipped: true)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = cx
}

func UIGraphicsPopContext()
{
    NSGraphicsContext.restoreGraphicsState()
}

private var imageContextStack: [CGFloat] = []

func UIGraphicsBeginImageContextWithOptions(_ size: CGSize, _ opaque: Bool, _ scale: CGFloat)
{
    var scale = scale
    if scale == 0.0
    {
        scale = NSScreen.main?.backingScaleFactor ?? 1.0
    }
    
    let width = Int(size.width * scale)
    let height = Int(size.height * scale)
    
    if width > 0 && height > 0
    {
        imageContextStack.append(scale)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4*width, space: colorSpace, bitmapInfo: (opaque ?  CGImageAlphaInfo.noneSkipFirst.rawValue : CGImageAlphaInfo.premultipliedFirst.rawValue))
            else { return }
        
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(height)))
        ctx.scaleBy(x: scale, y: scale)
        UIGraphicsPushContext(ctx)
    }
}

func UIGraphicsGetImageFromCurrentImageContext() -> UIImage?
{
    if !imageContextStack.isEmpty
    {
        guard let ctx = UIGraphicsGetCurrentContext()
            else { return nil }
        
        let scale = imageContextStack.last!
        if let theCGImage = ctx.makeImage()
        {
            let size = CGSize(width: CGFloat(ctx.width) / scale, height: CGFloat(ctx.height) / scale)
            let image = UIImage(cgImage: theCGImage, size: size)
            return image
        }
    }
    return nil
}

func UIGraphicsEndImageContext()
{
    if imageContextStack.last != nil
    {
        imageContextStack.removeLast()
        UIGraphicsPopContext()
    }
}


#endif

