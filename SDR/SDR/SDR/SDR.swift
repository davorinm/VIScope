import Foundation

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
}
