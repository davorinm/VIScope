import Foundation

// TODO: Divide SDRDevice to public and internal protocols
// SDRDevice -> public
// SDRDeviceInternal -> private

// TODO: Change func getters to readonly properties
// TODO: Changable properties to readonly observers

public protocol SDRDevice {
    /// name of SDR device
    var name: String { get }
    
    /// Samples produced by SDR device, float -1...1
    var samples: ObservableEvent<[Float]> { get }
    
    /// Minimum tunable frequency
    var minimumFrequency: Int { get }
    
    /// Maximum tunable frequency
    var maximumFrequency: Int { get }
    
    var sampleRate: Int { get set }
    func sampleRateList() -> [Int]
    
    var tunedFrequency: Int { get set }
    
    var frequencyCorrection: Int { get set }
    
    func tunerGainArray() -> [Int]
    
    var tunerAutoGain: Bool { get set }
    
    var tunerGain: Int { get set }
    
    var isOpen: Bool { get }
    var isConfigured: Bool { get }
    
    func startSampleStream()
    func stopSampleStream()
}
