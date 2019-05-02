//
//  HistogramChartView.swift
//  ViScope
//
//  Created by Davorin Madaric on 29/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa

public final class HistogramChartView: NSView {
    private var data: [[Double]] = []
    
    private var colorSpace: CGColorSpace! {
         return CGColorSpaceCreateDeviceRGB()
    }
    
    private var currentContext: CGContext? {
        return NSGraphicsContext.current?.cgContext
    }
    
    public func addData(_ samples: [Double]) {
        data.insert(samples, at: 0)
        
        if data.count > 200 {
            data.removeLast()
        }
        
        DispatchQueue.main.async {
            self.setNeedsDisplay(self.bounds)
        }
    }
    
    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // TODO: Optimize
//        drawCGContext()
        drawCGImage()
    }
    
    private func drawCGContext() {
        guard data.count > 0 else {
            return
        }
        
        let width  = Int(self.bounds.width)
        let height = Int(self.bounds.height)
        
        // Create single array
        let fff: [Double] = data.flatMap { $0 }
        
        // Map Double to RGBA
        let pixelDataTemp: [[UInt8]] = fff.map { (val) -> [UInt8] in
            
            let r = UInt8(val * 255)
            let g = UInt8(0.5 * 255)
            let b = UInt8(0.5 * 255)
            let a = UInt8(1 * 255)
            
            
            //            let res: UInt32 = UInt32(r << 24 | g << 16 | b << 8 | a)
            return [r, g, b, a]
        }
        
        // Another pixel data single array
        var pixelData: [UInt8] = pixelDataTemp.flatMap { $0 }
        
        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: data.count,
                                      bitsPerComponent: 8,
                                      bytesPerRow: data[0].count * 4,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                                        print("context is nil")
                                        return
        }


        guard let img = context.makeImage() else {
            print("img is nil")
            return
        }
        
        let rrr = CGRect(x: 0, y: 0, width: width, height: height)
        currentContext?.draw(img, in: rrr)
    }
    
    private func drawCGImage() {
        let width  = Int(self.bounds.width)
        let height = Int(self.bounds.height)
        
        // Create single array
        let fff: [Double] = data.flatMap { $0 }
        
        // Map Double to RGBA
        let pixelDataTemp: [[UInt8]] = fff.map { (val) -> [UInt8] in
            
            let r = UInt8(val * 255)
            let g = UInt8(val * 255)
            let b = UInt8(val * 255)
            let a = UInt8(val * 255)
            
            
            //            let res: UInt32 = UInt32(r << 24 | g << 16 | b << 8 | a)
            return [r, g, b, a]
        }
        
        // Another pixel data single array
        var pixelData: [UInt8] = pixelDataTemp.flatMap { $0 }
        
        
        let pixels: NSData = NSData(bytes: &pixelData, length: pixelData.count)
        
        let dataProvider = CGDataProvider(data: pixels as CFData)!
        
        guard let ggg: CGImage = CGImage(width: width,
                                         height: data.count,
                                         bitsPerComponent: 8,
                                         bitsPerPixel: 32,
                                         bytesPerRow: data[0].count * 4,
                                         space: colorSpace,
                                         bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                         provider: dataProvider,
                                         decode: nil,
                                         shouldInterpolate: false,
                                         intent: CGColorRenderingIntent.defaultIntent) else {
                                            print("CGImage is nil")
                                            return
        }
        
        let rrr = CGRect(x: 0, y: 0, width: width, height: height)
        currentContext?.draw(ggg, in: rrr)
    }
}
