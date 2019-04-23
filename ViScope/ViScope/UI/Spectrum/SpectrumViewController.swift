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

class SpectrumViewController: NSViewController, ChartDelegate {
    @IBOutlet private weak var spectrumChart: SpectrogramView!
    @IBOutlet private weak var waterfallChart: Chart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        spectrumChart.delegate = self
//        waterfallChart.delegate = self
        
        SDR.samples.subscribe(self) { [unowned self] (samples) in
            print("samples in")
            
            self.spectrumChart.data = samples.sampes()
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

