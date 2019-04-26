//
//  SpectrumViewController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 18/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import AppKit
import SwiftChart
import SDR

//https://developer.apple.com/documentation/accelerate/vdsp/discrete_fourier_transforms/signal_extraction_from_noise
//https://developer.apple.com/documentation/accelerate/vdsp/discrete_fourier_transforms/equalizing_audio_with_vdsp
//
//
//https://www.objc.io/issues/16-swift/rapid-prototyping-in-swift-playgrounds/
//https://stackoverflow.com/questions/14872635/fft-with-ios-vdsp-not-symmetrical
//
//https://github.com/hyperjeff/Accelerate-in-Swift/blob/master/FFT.playground/contents.swift
//https://github.com/hyperjeff/Accelerate-in-Swift/blob/master/vDSP.playground/contents.swift
//
//https://github.com/christopherhelf/Swift-FFT-Example/blob/master/ffttest/fft.swift

class SpectrumViewController: NSViewController, ChartDelegate {
    @IBOutlet private weak var spectrumChart: SpectrogramView!
    @IBOutlet private weak var waterfallChart: Chart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        spectrumChart.delegate = self
//        waterfallChart.delegate = self
        
        SDR.spectrumData.subscribe(self) { [unowned self] (samples) in
            print("samples in")
            
            self.spectrumChart.data = samples.samples()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        
        initializeSpectrumChart()
        initializeWaterfallChart()
    }
    
    // MARK: - Charts Init
    
    private func initializeSpectrumChart() {
        
    }
    
    private func initializeWaterfallChart() {
        
    }
    
    // MARK: - ChartDelegate
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            print(value)
        }
        
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    
    // MARK: - Helpers
    
    func getStockValues() -> [Int] {
        let array = (0..<300).map { _ in Int.random(in: 0 ..< 10) }
        return array
    }
}

