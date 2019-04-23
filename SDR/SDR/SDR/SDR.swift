import Foundation
import Accelerate

public class SDR {
    /// Singelton of shared SDR
    static let shared = SDR()
    
    let devices: ObservableProperty<[String]> = ObservableProperty(value: [])
    let selectedDevice: ObservableProperty<SDRDevice?> = ObservableProperty(value: nil)
    let samples: ObservableEvent<SDRSamples> = ObservableEvent()
    
    private init() {
        USB.shared.registerEvents()
        
        devices.value = RTLSDR.deviceList().map { $0.name }
    }
    
    // MARK: - Devices
    
    func selectDevice(_ index: Int) {
        let device = RTLSDR.deviceList()[index]
        selectedDevice.value = device
        
        
        device.rawSamples.subscribe(self) { [unowned self] (samples) in
            self.dequeueSamples(samples)
        }
        
        device.startSampleStream()
    }
    
    func tunedFrequency(_ frequency: Int) {
        selectedDevice.value?.tunedFrequency(frequency: frequency)
    }
    
    // MARK: - Prepare samples
    
    func dequeueSamples(_ rawSamples: [UInt8]) {
        // get samples count
        let sampleLength = vDSP_Length(rawSamples.count)
        let sampleCount  = rawSamples.count
        
        // create stride constants
        let strideOfOne = vDSP_Stride(1)
        
        // create scalers
        var addScaler:  Double = -127.5
        var divScaler:  Double = 127.5
        
        // create Double array
        var doubleSamples: [Double] = [Double](repeating: 0.0, count: sampleCount)
        
        // convert the raw UInt8 values into Doubles
        vDSP_vfltu8D(rawSamples, strideOfOne, &doubleSamples, strideOfOne, sampleLength)
        
        // convert 0.0 ... 255.0 -> -127.5 ... 127.5
        vDSP_vsaddD(doubleSamples, strideOfOne, &addScaler, &doubleSamples, strideOfOne, sampleLength)
        
        // normalize values to -1.0 -> 1.0
        vDSP_vsdivD(doubleSamples, strideOfOne, &divScaler, &doubleSamples, strideOfOne, sampleLength)
        
        // create samples object
        guard let sdrSamples = SDRSamples(doubleSamples) else {
            print("ERROR SDRSamples(doubleSamples")
            return
        }
        
        samples.raise(sdrSamples)
    }
}

extension SDR {
    public class var devices: ObservableProperty<[String]> {
        return SDR.shared.devices
    }
    
    public class func selectDevice(_ index: Int) {
        SDR.shared.selectDevice(index)
    }
    
    public class var selectedDevice: ObservableProperty<SDRDevice?> {
        return SDR.shared.selectedDevice
    }
    
    public class var samples: ObservableEvent<SDRSamples> {
        return SDR.shared.samples
    }
}
