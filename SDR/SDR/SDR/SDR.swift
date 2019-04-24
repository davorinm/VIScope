import Foundation

public class SDR {
    public class var availableDevices: ObservableProperty<[String]> {
        return SoftwareDefinedRadio.shared.availableDevices
    }
    
    public class func bindDevice(_ index: Int) {
        SoftwareDefinedRadio.shared.bindDevice(index)
    }
    
    public class var bindedDevices: ObservableProperty<[SDRDevice]> {
        return SoftwareDefinedRadio.shared.bindedDevices
    }
    
    public class var samples: ObservableEvent<SDRSamples> {
        return SoftwareDefinedRadio.shared.samples
    }
}
