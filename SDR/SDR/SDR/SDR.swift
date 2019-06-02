import Foundation

/// SDR class
public class SDR {
    /// SDR Devices
    public class var devices: ObservableProperty<[SDRDevice]> {
        return SoftwareDefinedRadio.shared.devices
    }
    
    /// Create a new device from multiple SDRDevices
    public class func createDevice(_ devices: [SDRDevice]) {
        SoftwareDefinedRadio.shared.createDevice(devices)
    }
    
    /// Start sampling device
    public class func startDevice(_ device: SDRDevice) {
         SoftwareDefinedRadio.shared.startDevice(device)
    }
    
    /// Spectrum data from SDR
    public class var spectrum: SDRSpectrum {
        return SoftwareDefinedRadio.shared.spectrum
    }
    
    /// Spectrum data from intermediate frequency SDR
    public class var ifSpectrum: SDRSpectrum {
        return SoftwareDefinedRadio.shared.ifSpectrum
    }
}

/// SDRSpectrum class for spectrum data
public class SDRSpectrum {
    public struct Span {
        let start: Int
        let end: Int
    }
    
    /// Frequency span of spectrum
    public let span: ObservableProperty<Span> = ObservableProperty(value: Span(start: 0, end: 0))
    
    /// Width of spectrum data in points
    public let width: ObservableFilteredProperty<Int> = ObservableFilteredProperty(value: 0)
    
    /// Observable spectrum data
    public let data: ObservableEvent<[Float]> = ObservableEvent()
}
