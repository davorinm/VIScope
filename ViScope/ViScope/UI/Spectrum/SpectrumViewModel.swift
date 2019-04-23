//
//  SpectrumViewModel.swift
//  ViScope
//
//  Created by Davorin Madaric on 21/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation
import SDR

class SpectrumViewModel {
    
    private var fftDisposable: Disposable?
    
    
    
    
    func load() {
        
//        fftDisposable = SDR.shared.fft.subscribe { [unowned self] (fft) in
//            
//            let series = ChartSeries(fft)
//            series.area = true
//            
//            self.spectrumChart.series = [series]
//        }
        
        
    }
    
    func unload() {
        
        fftDisposable = nil
    }
    
}
