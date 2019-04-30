//
//  SoftwareDefinedRadio.swift
//  SDR
//
//  Created by Davorin Mađarić on 24/04/2019.
//  Copyright © 2019 Davorin Madaric. All rights reserved.
//

import Foundation

//https://github.com/FutureKit/FutureKit/blob/master/FutureKit/FutureFIFO.swift
//
//https://albertodebortoli.com/2018/02/12/the-easiest-promises-in-swift/
//https://github.com/mxcl/PromiseKit
//
//class StuffMaker {
//    func iBuildStuffWithFutures() -> Future<NSData> {
//        let p = Promise<NSData>()
//        dispatch_async(self.mycustomqueue)  {
//            // do stuff to make your NSData
//            if (SUCCESS) {
//                let goodStuff = NSData()
//                p.completeWithSuccess(goodStuff)
//            }
//            else {
//                p.completeWithFail(NSError())
//            }
//        }
//        return p.future()
//    }
//}

class SoftwareDefinedRadio {
    /// Singelton of shared SoftwareDefinedRadio
    static let shared = SoftwareDefinedRadio()
    
    let availableDevices: ObservableProperty<[SDRDevice]> = ObservableProperty(value: [])
    let bindedDevices: ObservableProperty<[SDRDevice]> = ObservableProperty(value: [])
    let spectrumData: ObservableEvent<[Double]> = ObservableEvent()
    
    private var devices: [SDRDevice] = []
    private var radio: Radio?
    
    private var scheduledTimer: Timer!
    
    private init() {
        devices = RTLSDR.deviceList() + [NoiseSDRDevice()]
        radio = prepareChain()
        
        USB.shared.onChange = { [unowned self] in
            self.updateDevices()
        }
        
        availableDevices.value = devices
        
        
        
        
//        let ttt = FutureChain.create().then { (Int) -> Future<Int> in
//            
//            return Future { _ in
//                
//            }
//            
//            }.then { (val: Int) -> Future<Double> in
//                return 5.5
//        }
        
        
        
        scheduledTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] (timer) in
            if let data = self?.testSpectrumData() {
                self?.spectrumData.raise(data)
            }
        }
    }
    
    // MARK: -
    
    private func updateDevices() {
        devices = RTLSDR.deviceList() + [NoiseSDRDevice()]
    }
    
    // MARK: - Devices
    
    func bindDevice(_ index: Int) {
        let device = RTLSDR.deviceList()[index]
        bindedDevices.value.append(device)
        
        
        device.rawSamples.subscribe(self) { [unowned self] (samples) in
            self.radio?.samplesIn(samples)
        }
        
        device.startSampleStream()
    }
    
    func prepareChain() -> Radio {
        let normalize = NormalizeBlock(bits: 8)
        let fft = FFTBlock()
        
        let radio = Radio()
        radio.addBlock(normalize)
        radio.addBlock(fft)
        
        return radio
    }
    
    // MARK: - Test
    
    private func testSpectrumData() -> [Double] {
        let array = (0..<1000).map { _ in Int.random(in: 0 ..< 1000) }
        
        let mapped = array.map { (val) -> Double in
            return Double(val) / 1000
        }
        
        return mapped
    }
}
