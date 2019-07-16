//
//  SpectrumViewController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 18/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa
import SDR
import SDRControls

class SpectrumViewController: NSViewController {
    @IBOutlet private weak var spectrumChart: FrequencyChartView!
    @IBOutlet private weak var spectrumUpperStepper: NSStepper!
    @IBOutlet private weak var spectrumLowerStepper: NSStepper!
    
    @IBOutlet private weak var waterfallChart: FrequencyHistogramView!
    @IBOutlet private weak var waterfallUpperStepper: NSStepper!
    @IBOutlet private weak var waterfallLowerStepper: NSStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SpectrumViewController viewDidLoad")
        print("\(spectrumChart.bounds.width)")
        
        // TODO: Implement better
        SDR.spectrum.span.subscribe(self) { [unowned self] (span) in
            print(span)
//            self.spectrumChart.startLabel = frequencyStart
//            self.waterfallChart.startLabel = frequencyStart
        }
    
        // TODO: Implement better
        SDR.spectrum.data.subscribe(self) { [unowned self] (spectrum) in
            self.spectrumChart.setData(spectrum)
            
            // TODO: Implement averaging window
            // vDSP_vavlin
            self.waterfallChart.addData(spectrum)
        }
        
        self.spectrumUpperStepper.increment = 10
        self.spectrumUpperStepper.minValue = -1000
        self.spectrumUpperStepper.maxValue = 1000
        self.spectrumUpperStepper.floatValue = 100
        
        self.spectrumLowerStepper.increment = 10
        self.spectrumLowerStepper.minValue = -1000
        self.spectrumLowerStepper.maxValue = 1000
        self.spectrumLowerStepper.floatValue = -100
        
//        self.waterfallUpperStepper.increment = 10
//        self.waterfallUpperStepper.maxValue = -1000
//        self.waterfallUpperStepper.floatValue = 100
//
//        self.waterfallLowerStepper.increment = 10
//        self.waterfallLowerStepper.floatValue = -100
        
//        self.spectrumChart.max = 10000
//        self.spectrumChart.min = -200
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
    }
    
//    var timer: Timer!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (ttt) in
//            
//            
//            // TODO: Test chart data
//            let data: [Float] = (0..<1024).map { Float($0) }
//            self.spectrumChart.setData(data)
//            
//            
////            // TODO: Test waterfall data
////            let wData: [[Float]] = (0..<500).map { (val) -> [Float] in
////                return (0..<1024).map { Float($0) }
////            }
////            self.waterfallChart.setData(wData)
//            self.waterfallChart.addData(data)
//            
//        })
        
        
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        // TODO: Implement better
        SDR.spectrum.width.value = Int(spectrumChart.bounds.width)
        
        print("SpectrumViewController viewDidLayout")
        print("\(spectrumChart.bounds.width)")
        print("\(self.view.bounds.width)")
        // TODO: If this works, report width for samples intepolation... or maybe should we be doing this in charts?!?
    }
    
    // MARK: - Actions
    
    @IBAction func spectrumUpperStepperChanged(_ sender: Any) {
        self.spectrumChart.max = self.spectrumUpperStepper.floatValue
        print("spectrumChart.max \(self.spectrumChart.max)")
    }
    
    @IBAction func spectrumLowerStepperChanged(_ sender: Any) {
        self.spectrumChart.min = self.spectrumLowerStepper.floatValue
        print("spectrumChart.min \(self.spectrumChart.min)")
    }
    
    @IBAction func waterfallUpperStepperChanged(_ sender: Any) {
        self.waterfallChart.max = self.waterfallUpperStepper.floatValue
        print("waterfallChart.max \(self.waterfallChart.max)")
    }

    @IBAction func waterfallLowerStepperChanged(_ sender: Any) {
        self.waterfallChart.min = self.waterfallLowerStepper.floatValue
        print("waterfallChart.min \(self.waterfallChart.min)")
    }
}

