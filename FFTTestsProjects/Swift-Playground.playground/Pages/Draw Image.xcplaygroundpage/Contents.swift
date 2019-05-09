import AppKit

// Choose the right drawing technology
// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CocoaDrawingGuide/QuartzOpenGL/QuartzOpenGL.html#//apple_ref/doc/uid/TP40003290-CH211-SW2


// Draw in CoreGraphics
func DrawImageInCGContext(size: CGSize, drawFunc: (context: CGContextRef) -> ()) -> NSImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
    let context = CGBitmapContextCreate(
        nil,
        Int(size.width),
        Int(size.height),
        8,
        0,
        colorSpace,
        bitmapInfo.rawValue)
    
    drawFunc(context: context!)
    
    let image = CGBitmapContextCreateImage(context)
    return NSImage(CGImage: image!, size: size)
}

// Draw in NSGraphicsContext, a layer on top of CoreGraphics
func DrawImageInNSGraphicsContext(size: CGSize, drawFunc: ()->()) -> NSImage {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: NSCalibratedRGBColorSpace,
        bytesPerRow: 0,
        bitsPerPixel: 0)
    
    let context = NSGraphicsContext(bitmapImageRep: rep!)
    
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.setCurrentContext(context)
    
    drawFunc()
    
    NSGraphicsContext.restoreGraphicsState()
    
    let image = NSImage(size: size)
    image.addRepresentation(rep!)
    
    return image
}

let rect = CGRectMake(0, 0, 255, 255)

let image1 = DrawImageInCGContext(rect.size) { (context) -> () in
    CGContextSetFillColorWithColor(context, NSColor.redColor().CGColor)
    CGContextFillRect(context, rect);
    
}


let image2 = DrawImageInNSGraphicsContext(rect.size) { () -> () in
    NSColor.blueColor().set()
    NSRectFill(rect)
    
}