import Foundation

public class SDR {
    public class var availableDevicesNames: ObservableProperty<[String]> {
        return SoftwareDefinedRadio.shared.devices
    }
    
    public class func selectDevice(_ index: Int) {
        SoftwareDefinedRadio.shared.selectDevice(index)
    }
    
    public class var selectedDevice: ObservableProperty<SDRDevice?> {
        return SoftwareDefinedRadio.shared.selectedDevice
    }
    
    public class var samples: ObservableEvent<SDRSamples> {
        return SoftwareDefinedRadio.shared.samples
    }
}
