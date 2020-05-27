/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of iOS view controller that demonstrates audio equalization.
*/

import UIKit
import Accelerate

let sampleCount = 512

class ViewController: UIViewController {
    
    var equalizationMode: EqualizationMode = .flat {
        didSet {
            if let multiplier = equalizationMode.dctMultiplier() {
                GraphUtility.drawGraphInLayer(envelopeLayer,
                                              strokeColor: UIColor.red.withAlphaComponent(0.25).cgColor,
                                              lineWidth: 1,
                                              values: multiplier,
                                              minimum: -1,
                                              maximum: 2)
            } else {
                envelopeLayer.path = nil
            }
        }
    }
    
    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBAction func segmentedControlHandler(_ sender: Any) {
        guard
            let segmentedControl = sender as? UISegmentedControl,
            let modeName = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex),
            let mode = EqualizationMode(rawValue: modeName) else {
                return
        }
        
        switch mode {
        case .biquadLowPass, .biquadHighPass:
            biquadFilter = vDSP.Biquad(coefficients: mode.biquadCoefficients()!,
                                       channelCount: 1,
                                       sectionCount: 1,
                                       ofType: Float.self)
        default:
            break
        }
        
        equalizationMode = mode
    }
    
    var biquadFilter: vDSP.Biquad<Float>?
    
    let forwardDCT = vDSP.DCT(count: sampleCount,
                              transformType: .II)
    
    let inverseDCT = vDSP.DCT(count: sampleCount,
                              transformType: .III)
    
    var frequencyDomainGraphLayerIndex = 0
    let frequencyDomainGraphLayers = [CAShapeLayer(), CAShapeLayer(),
                                      CAShapeLayer(), CAShapeLayer()]
    
    let envelopeLayer = CAShapeLayer()
    
    lazy var forwardDCT_PreProcessed = [Float](repeating: 0,
                                               count: sampleCount)
    
    lazy var forwardDCT_PostProcessed = [Float](repeating: 0,
                                                count: sampleCount)
    
    lazy var inverseDCT_Result = [Float](repeating: 0,
                                  count: sampleCount)
    
    lazy var audioProvider: AudioProvider = AudioProviderImpl()
        
    var pageNumber = 0
    
    var buffer: [Float] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.removeAllSegments()
        EqualizationMode.allCases.forEach {
            segmentedControl.insertSegment(withTitle: $0.rawValue,
                                           at: segmentedControl.numberOfSegments,
                                           animated: false)
        }
        
        if let defaultIndex = EqualizationMode.allCases.firstIndex(of: equalizationMode) {
            segmentedControl.selectedSegmentIndex = defaultIndex
        }
        
        frequencyDomainGraphLayers.forEach {
            view.layer.addSublayer($0)
        }
        
        envelopeLayer.fillColor = nil
        view.layer.addSublayer(envelopeLayer)

        audioProvider.configureAudioOutput { () -> [Float] in
            
            
            return self.buffer
        }
        
        audioProvider.samplesData.subscribe(self) { [unowned self] (samples) in
            DispatchQueue.main.async {
                self.buffer = self.processSignal(samples: samples.samples)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        audioProvider.startRecording()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        audioProvider.stopRecording()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        frequencyDomainGraphLayers.forEach {
            $0.frame = view.frame.insetBy(dx: 0, dy: 50)
        }
        
        envelopeLayer.frame = view.frame.insetBy(dx: 0, dy: 50)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

extension ViewController {
    // Returns a page containing `sampleCount` samples from the
    // `samples` array and increments `pageNumber`.
    func processSignal(samples: [Float]) -> [Float] {
        let start = pageNumber * sampleCount
        let end = (pageNumber + 1) * sampleCount
        
        let page = Array(samples[start ..< end])
        
        pageNumber += 1
        
        if (pageNumber + 1) * sampleCount >= samples.count {
            pageNumber = 0
        }
        
        let outputSignal: [Float]
        
        switch equalizationMode.category {
            case .biquad:
                outputSignal = apply(toInput: page)
            case let .dct(dctMultiplier):
                outputSignal = apply(dctMultiplier: dctMultiplier, toInput: page)
            case .passThrough:
                outputSignal = page
        }
        
        renderSignalAsFrequencyDomainGraph(signal: outputSignal)
        
        return outputSignal
    }
    
    // Applies `biquadFilter` to the values in `input` and
    // returns the result.
    func apply(toInput input: [Float]) -> [Float] {
        return biquadFilter!.apply(input: input)
    }
    
    // Multiplies the frequency-domain representation of `input` by
    // `dctMultiplier`, and returns the temporal-domain representation
    // of the product.
    func apply(dctMultiplier: [Float], toInput input: [Float]) -> [Float] {
        // Perform forward DCT.
        forwardDCT?.transform(input,
                              result: &forwardDCT_PreProcessed)
        // Multiply frequency-domain data by `dctMultiplier`.
        vDSP.multiply(dctMultiplier,
                      forwardDCT_PreProcessed,
                      result: &forwardDCT_PostProcessed)
        
        // Perform inverse DCT.
        inverseDCT?.transform(forwardDCT_PostProcessed,
                              result: &inverseDCT_Result)
        
        // In-place scale inverse DCT result by n / 2.
        // Output samples are now in range -1...+1
        vDSP.divide(inverseDCT_Result,
                    Float(sampleCount / 2),
                    result: &inverseDCT_Result)
        
        return inverseDCT_Result
    }
    
    func renderSignalAsFrequencyDomainGraph(signal: [Float]) {
        guard let frequencyDomain = forwardDCT?.transform(signal) else {
            return
        }
        
        DispatchQueue.main.async {
            let index = self.frequencyDomainGraphLayerIndex % self.frequencyDomainGraphLayers.count
            
            GraphUtility.drawGraphInLayer(self.frequencyDomainGraphLayers[index],
                                          strokeColor: UIColor.blue.withAlphaComponent(1).cgColor,
                                          lineWidth: 2,
                                          values: frequencyDomain,
                                          minimum: -20,
                                          maximum: 20,
                                          hScale: 1)
            
            self.frequencyDomainGraphLayers.forEach {
                if let alpha = $0.strokeColor?.alpha {
                    $0.strokeColor = UIColor.blue.withAlphaComponent(alpha * 0.75).cgColor
                }
            }
            
            self.frequencyDomainGraphLayerIndex += 1
        }
    }
}
