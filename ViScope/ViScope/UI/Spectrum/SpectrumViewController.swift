//
//  SpectrumViewController.swift
//  ViScope
//
//  Created by Davorin Mađarić on 18/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Cocoa
import DMSpectrum
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

class SpectrumViewController: NSViewController {
    @IBOutlet private weak var spectrumChart: SpectrumView!
    @IBOutlet private weak var waterfallChart: HistogramView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SpectrumViewController viewDidLoad")
        print("\(spectrumChart.bounds.width)")
        
//        SDR.spectrumData.subscribe(self) { [unowned self] (spectrum) in            
//            self.spectrumChart.setData(spectrum)
//            self.waterfallChart.addData(spectrum)
//        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        print("SpectrumViewController viewDidLayout")
        print("\(spectrumChart.bounds.width)")
        // TODO: If this works, report width for samples intepolation... or maybe should we be doing this in charts?!?
    }
}

