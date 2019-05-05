import Foundation

public class SDR {
    /// Devices that are availabe to be binded
    public class var availableDevices: ObservableProperty<[SDRDevice]> {
        return SoftwareDefinedRadio.shared.availableDevices
    }
    
    /// Devices that are binded to SDR
    public class var bindedDevices: ObservableProperty<[SDRDevice]> {
        return SoftwareDefinedRadio.shared.bindedDevices
    }
    
    /// Bind device from availableDevices list
    public class func bindDevice(_ device: SDRDevice) {
        SoftwareDefinedRadio.shared.bindDevice(device)
    }
    
    /// Spectrum data from SDR
    public class var spectrumData: ObservableEvent<[Float]> {
        return SoftwareDefinedRadio.shared.spectrumData
    }
}
