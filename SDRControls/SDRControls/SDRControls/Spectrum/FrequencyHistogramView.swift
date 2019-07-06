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
    
    private let colors: Colors = Colors()
    
    private var samplesData: [[Float]] = []
    private var pixelsData = Data()
    
    private let transformFilter = CIFilter(name: "CILanczosScaleTransform")!
    
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
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[metalView]|", options: [], metrics: nil, views: ["metalView" : metalView!]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[metalView]|", options: [], metrics: nil, views: ["metalView" : metalView!]))
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
            if samplesData.count > 400 {
                samplesData.removeLast()
            }
        }
        
        processData()
    }
    
    public func addData(_ samples: [Float]) {
        if min == nil, let sampleMin = samples.min() {
            min = sampleMin
        }
        
        if max == nil, let sampleMax = samples.max() {
            max = sampleMax
        }
        
        samplesData.insert(samples, at: 0)
        if samplesData.count > 400 {
            samplesData.removeLast()
        }
        
        processData()
    }
    
    private func processData() {
        guard samplesData.count > 0 else {
            return
        }
        
        let range = max - min
        let width = samplesData[0].count
        let height = samplesData.count
        let bytesPerRow = width * 4
        
        // Create pixels data
        let pixelsDataCapacity = bytesPerRow * height
        pixelsData.reserveCapacity(pixelsDataCapacity)
        pixelsData.removeAll(keepingCapacity: true)
        
        // Fill pixels data
        for samples in samplesData {
            for sample in samples {
                let scaledValue = (sample - min) / range
                let colorValue = self.colors.colorForValue2(scaledValue)
                pixelsData.append(contentsOf: colorValue)
            }
        }
        
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
        let aspectRatio = 1
        
        transformFilter.setValue(image, forKey: kCIInputImageKey)
        transformFilter.setValue(scale, forKey: kCIInputScaleKey)
        transformFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        guard let outputImage = transformFilter.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("Filter output image error")
            return
        }
        
        // Set image to renderer
        metalRender.setImage(outputImage)
        
        // Draw
        metalView.setNeedsDisplay(metalView.bounds)
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
