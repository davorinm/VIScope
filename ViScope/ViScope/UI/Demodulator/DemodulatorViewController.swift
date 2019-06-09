//
//  DemodulatorViewController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import AppKit
import SDR
import SDRControls

class DemodulatorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet private weak var spectrumChart: FrequencyChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DemodulatorViewController viewDidLoad")
        print("\(spectrumChart.bounds.width)")
        
        
        // TODO: Implement better
        SDR.ifSpectrum.data.subscribe(self) { [unowned self] (spectrum) in
            self.spectrumChart.setData(spectrum)
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        // TODO: Implement better
        SDR.ifSpectrum.width.value = Int(spectrumChart.bounds.width)
        
        print("SpectrumViewController viewDidLayout")
        print("\(spectrumChart.bounds.width)")
        // TODO: If this works, report width for samples intepolation... or maybe should we be doing this in charts?!?
    }
}
