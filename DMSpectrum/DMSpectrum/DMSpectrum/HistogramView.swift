//
//  Hist.swift
//  DMSpectrum
//
//  Created by Davorin Madaric on 02/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Cocoa
import Metal
import MetalKit

public final class HistogramView: NSView {
    private var metalView: MTKView!
    private var metalRender: MetalRender!
    
    private let colors: Colors = Colors()
    
    private var data: [[UInt8]] = []
    private var pixels: Data = Data()
    
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
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Can't use Metal")
        }
        
        metalView = MTKView(frame: NSRect.zero, device: device)
        metalRender = MetalRender(device: device)
        
        metalView.delegate = metalRender
        
        metalView.framebufferOnly = false
        metalView.enableSetNeedsDisplay = false
        metalView.isPaused = true
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        metalView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(metalView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[metalView]|", options: [], metrics: nil, views: ["metalView" : metalView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[metalView]|", options: [], metrics: nil, views: ["metalView" : metalView]))
    }
    
    // MARK: - Data
    
    public func addData(_ samples: [Double]) {
        // Map Double to RGBA color for sample value
        let pixelDataTemp: [[UInt8]] = samples.map { [unowned self] (val) -> [UInt8] in
            return self.colors.colorForValue2(val)
        }
        
        // Another pixel data single array
        let pixelData: [UInt8] = pixelDataTemp.flatMap { $0 }
        
        
        
        
        data.insert(pixelData, at: 0)
        
        if data.count > 200 {
            data.removeLast()
        }
        
        // Create single array
        var fff: [UInt8] = data.flatMap { $0 }
        
        
        
        
        
        pixels = Data(bytes: &fff, count: fff.count)
        
        
        metalRender.setImage(generateImage())
        
//        DispatchQueue.main.async {
            self.metalView.draw()
//        }
    }
    
    // MARK: - Drawing
    
    private func generateImage() -> CIImage? {
        guard data.count > 0 else {
            return nil
        }
        
        let size = CGSize(width: data[0].count / 4,
                          height: data.count)
        
        return CIImage(bitmapData: pixels,
                       bytesPerRow: data[0].count,
                       size: size,
                       format: CIFormat.RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
    }
}

private class MetalRender: NSObject, MTKViewDelegate {
    private var image: CIImage?
    
    private let context: CIContext
    private let commandQueue: MTLCommandQueue
    
    init?(device: MTLDevice) {
        commandQueue = device.makeCommandQueue(maxCommandBufferCount: 5)!
        context = CIContext(mtlDevice: device, options: [CIContextOption.useSoftwareRenderer:false])
    
        super.init()
    }
    
    func setImage(_ image: CIImage?) {
        self.image = image
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("drawableSizeWillChange \(size)")
    }
    
    func draw(in view: MTKView) {
        guard let drawImage: CIImage = self.image else {
            return
        }
        
        guard let commandBuffer = commandQueue.makeCommandBufferWithUnretainedReferences() else {
            return
        }
        
        guard let texture = view.currentDrawable?.texture else {
            return
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 500, height: 500)
        let colorSpace = drawImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        
        context.render(drawImage, to: texture, commandBuffer: commandBuffer, bounds: bounds, colorSpace: colorSpace)
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
}
