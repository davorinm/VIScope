//
//  FrequencyHistogramView.swift
//  DMSpectrum
//
//  Created by Davorin Madaric on 02/05/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public final class FrequencyHistogramView: UIView {
    public var min: Float! {
        didSet {
            setNeedsDisplay()
        }
    }
    public var max: Float! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var metalView: MTKView!
    private var metalRender: MetalRender!
    private var samplesData: [[Float]] = []
    private let transformFilter = CIFilter(name: "CILanczosScaleTransform")!
    private let processQueue: DispatchQueue = DispatchQueue(label: "FrequencyHistogramView")
    
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
        
        self.canDrawConcurrently = true
        
        metalView = MTKView(frame: NSRect.zero, device: device)
        metalView.canDrawConcurrently = true
        metalRender = MetalRender(device: device)
        
        metalView.delegate = metalRender
        
        metalView.framebufferOnly = false
        metalView.enableSetNeedsDisplay = true
        metalView.isPaused = true
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        metalView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(metalView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[metalView]-0-|", options: [], metrics: nil, views: ["metalView" : metalView!]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[metalView]-0-|", options: [], metrics: nil, views: ["metalView" : metalView!]))
    }
    
    // MARK: - Data
    
    public func setData(_ samples: [[Float]]) {
        samplesData = []
        
        if min == nil || max == nil {
            if let firstSamples = samples.first {
                if min == nil, let sampleMin = firstSamples.min() {
                    min = sampleMin
                }
                
                if max == nil, let sampleMax = firstSamples.max() {
                    max = sampleMax
                }
            }
        }
        
        for sample in samples {
            samplesData.insert(sample, at: 0)
        }
        
        let ratio = CGFloat(samples.count) / CGFloat(metalView.frame.width)
        let overflow = samplesData.count - Int(self.bounds.height * ratio)
        if overflow > 0 {
            samplesData.removeLast(overflow)
        }
        
        processQueue.async {
            self.processData()
        }
    }
    
    public func addData(_ samples: [Float]) {
        if min == nil, let sampleMin = samples.min() {
            min = sampleMin
        }
        
        if max == nil, let sampleMax = samples.max() {
            max = sampleMax
        }
        
        samplesData.insert(samples, at: 0)
        
        let ratio = CGFloat(samples.count) / CGFloat(metalView.frame.width)
        let overflow = samplesData.count - Int(self.bounds.height * ratio)
        if overflow > 0 {
            samplesData.removeLast(overflow)
        }
        
        processQueue.async {
            self.processData()
        }
    }
    
    private func processData() {
        guard samplesData.count > 0 else {
            return
        }
        
        let range = max - min
        let width = samplesData[0].count
        let height = samplesData.count
        let bytesPerRow = width * 4
        
        let pixelsDataCapacity = bytesPerRow * height
        var pixelsData = Data(capacity: pixelsDataCapacity)
        
        Measure.start(tag: "Unsafe")
        
        let flattened = samplesData.flatMap { $0 }
//        flattened.forEach { (sample) in
//            let scaledValue = (sample - min) / range
//            let colorValue = Colors.colorForValue(scaledValue)
//            pixelsData.append(contentsOf: colorValue)
//        }

        flattened.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<Float>) in
            for i in stride(from: buffer.startIndex, to: buffer.endIndex, by: 1) {
                let sample = buffer[i]

                let scaledValue = (sample - min) / range
                let colorValue = Colors.colorForValue(scaledValue)
                pixelsData.append(contentsOf: colorValue)
            }
        }
        
        Measure.end(tag: "Unsafe")
        
        if pixelsData.isEmpty {
            print("pixelData error : empty")
            return
        }
        
        // Generate image
        let imageSize = CGSize(width: width, height: height)
        let image = CIImage(bitmapData: pixelsData,
                            bytesPerRow: bytesPerRow,
                            size: imageSize,
                            format: CIFormat.RGBA8,
                            colorSpace: CGColorSpaceCreateDeviceRGB())
        
        // Scale image
        let scale = metalView.drawableSize.width / imageSize.width
        transformFilter.setValue(image, forKey: kCIInputImageKey)
        transformFilter.setValue(scale, forKey: kCIInputScaleKey)
        guard let outputImage = transformFilter.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("Filter output image error")
            return
        }
        
        // Set image to renderer
        metalRender.setImage(outputImage)
        
        // Draw
        DispatchQueue.main.async {
            self.metalView.setNeedsDisplay(self.metalView.bounds)
        }
    }
}

private class MetalRender: NSObject, MTKViewDelegate {
    private var image: CIImage?
    
    private let context: CIContext
    private let commandQueue: MTLCommandQueue
    
    init?(device: MTLDevice) {
        commandQueue = device.makeCommandQueue(maxCommandBufferCount: 5)!
        context = CIContext(mtlDevice: device, options: [CIContextOption.useSoftwareRenderer: false])
    
        super.init()
    }
    
    func setImage(_ image: CIImage) {
        self.image = image
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("drawableSizeWillChange \(size)")
    }
    
    func draw(in view: MTKView) {
        guard let drawImage = self.image else {
            return
        }
        
        guard let commandBuffer = commandQueue.makeCommandBufferWithUnretainedReferences() else {
            return
        }
        
        guard let texture = view.currentDrawable?.texture else {
            return
        }
        
        context.render(drawImage,
                       to: texture,
                       commandBuffer: commandBuffer,
                       bounds: drawImage.extent,
                       colorSpace: drawImage.colorSpace ?? CGColorSpaceCreateDeviceRGB())
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
