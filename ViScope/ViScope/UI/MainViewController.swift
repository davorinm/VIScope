//
//  ViewController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 16/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa
import Charts

class MainViewController: NSViewController {

    override open func viewDidLoad() {
        super.viewDidLoad()
        
//        // Do any additional setup after loading the view.
//        let xArray = Array(1..<10)
//        let ys1 = xArray.map { x in return sin(Double(x) / 2.0 / 3.141 * 1.5) }
//        let ys2 = xArray.map { x in return cos(Double(x) / 2.0 / 3.141) }
//
//        let yse1 = ys1.enumerated().map { x, y in return BarChartDataEntry(x: Double(x), y: y) }
//        let yse2 = ys2.enumerated().map { x, y in return BarChartDataEntry(x: Double(x), y: y) }
//
//        let data = BarChartData()
//        let ds1 = BarChartDataSet(entries: yse1, label: "Hello")
//        ds1.colors = [NSUIColor.red]
//        data.addDataSet(ds1)
//
//        let ds2 = BarChartDataSet(entries: yse2, label: "World")
//        ds2.colors = [NSUIColor.blue]
//        data.addDataSet(ds2)
//
//        let barWidth = 0.4
//        let barSpace = 0.05
//        let groupSpace = 0.1
//
//        data.barWidth = barWidth
//        self.chartView.xAxis.axisMinimum = Double(xArray[0])
//        self.chartView.xAxis.axisMaximum = Double(xArray[0]) + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(xArray.count)
//        // (0.4 + 0.05) * 2 (data set count) + 0.1 = 1
//        data.groupBars(fromX: Double(xArray[0]), groupSpace: groupSpace, barSpace: barSpace)
//
//        self.chartView.data = data
//
//        self.chartView.gridBackgroundColor = NSUIColor.white
//
//        self.chartView.chartDescription?.text = "Barchart Demo"
    }
    
    override open func viewWillAppear() {
        super.viewWillAppear()
        
//        self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}

