//
//  SpectrumViewController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 18/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import AppKit
import SwiftChart

class SpectrumViewController: NSViewController, ChartDelegate {
    @IBOutlet private weak var spectrumChart: Chart!
    @IBOutlet private weak var waterfallChart: Chart!
    
    private var fftDisposable: Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spectrumChart.delegate = self
        waterfallChart.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        initializeSpectrumChart()
        initializeWaterfallChart()
        
        fftDisposable = SoftwareDefinedRadio.shared.fft.subscribe { [unowned self] (fft) in
            
            let series = ChartSeries(fft)
            series.area = true
            
            self.spectrumChart.series = [series]
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        fftDisposable = nil
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

