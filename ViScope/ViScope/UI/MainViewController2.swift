//
//  MainViewController2.swift
//  ViScope
//
//  Created by Davorin Mađarić on 18/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import AppKit
import SwiftChart

class MainViewController2: NSViewController, ChartDelegate {
    @IBOutlet private weak var chart: Chart!
    
    private let sdr: SoftwareDefinedRadio = SoftwareDefinedRadio()
    private var gameTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chart.delegate = self
        
        // Do any additional setup after loading the view.
        
        
        https://github.com/ABTSoftware/SciChart.iOS.Examples/tree/master/v2.x/Sandbox
        https://developer.apple.com/documentation/accelerate/vdsp#//apple_ref/doc/uid/TP40009464
        https://github.com/welbesw/CoreAudioMixer
        https://www.objc.io/issues/24-audio/functional-signal-processing/
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        initializeChart()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    }
    
    @objc func runTimedCode() {
        let stockValues = getStockValues()
        
        var serieData: [Double] = []
        //        var labels: [Double] = []
        //        var labelsAsString: Array<String> = []
        
        serieData = stockValues.map({ (val) -> Double in
            Double(val)
        })
        
        let series = ChartSeries(serieData)
        series.area = true
        
        
        chart.series = [series]
        
    }
    
    private func initializeChart() {
        // Initialize data series and labels
        let stockValues = getStockValues()
        
        var serieData: [Double] = []
//        var labels: [Double] = []
//        var labelsAsString: Array<String> = []
        
        serieData = stockValues.map({ (val) -> Double in
            Double(val)
        })
        
        
        // Date formatter to retrieve the month names
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        
        
        let series = ChartSeries(serieData)
        series.area = true
        
        // Configure chart layout
        
        chart.lineWidth = 0.5
        chart.labelFont = UIFont.systemFont(ofSize: 12)
//        chart.xLabels = labels
//        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
//            return labelsAsString[labelIndex]
//        }
        chart.xLabelsTextAlignment = .center
        chart.yLabelsOnRightSide = true
        // Add some padding above the x-axis
        chart.minY = serieData.min()! - 5
        
//        chart.add(series)
        
        chart.series = [series]
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
    
    func getStockValues() -> [Int] {
        let array = (0..<300).map { _ in Int.random(in: 0 ..< 10) }
        return array
    }
}

