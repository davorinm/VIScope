import Foundation

/// SDR class
public class SDR {
    /// SDR Devices
    public class var devices: ObservableProperty<[SDRDevice]> {
        return SoftwareDefinedRadio.shared.devices
    }
    
    /// Create SDR device
    public class func createDevice(_ devices: [SDRDevice]) {
        SoftwareDefinedRadio.shared.createDevice(devices)
    }
    
    /// Bind device from availableDevices list
    public class func bindDevice(_ device: SDRDevice) {
        SoftwareDefinedRadio.shared.bindDevice(device)
    }
    
    /// Spectrum data from SDR
    public class var spectrum: SDRSpectrum {
        return SoftwareDefinedRadio.shared.spectrum
    }
}

/// SDRSpectrum class for spectrum data
public class SDRSpectrum {
    /// Width of spectrum data in points
    public let width: ObservableProperty<Int> = ObservableProperty(value: 400)
    
    /// Observable spectrum data
    public let data: ObservableEvent<[Float]> = ObservableEvent()
}
