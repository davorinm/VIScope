import Foundation

// TODO: Divide SDRDevice to public and internal protocols
// SDRDevice -> public
// SDRDeviceInternal -> private

// TODO: Change func getters to readonly properties
// TODO: Changable properties to readonly observers

public protocol SDRDevice {
    var name: String { get }
    var rawSamples: ObservableEvent<[UInt8]> { get }
    
    var minimumFrequency: Int { get }
    var maximumFrequency: Int { get }
    
    var sampleRate: Int { get set }
    func sampleRateList() -> [Int]
    
    var tunedFrequency: Int { get set }
    
    var frequencyCorrection: Int { get set }
    
    func tunerGainArray() -> [Int]
    func tunerAutoGain() -> Bool
    func tunerAutoGain(auto: Bool)
    func tunerGain() -> Int
    func tunerGain(gain: Int)
    
    func isOpen() -> Bool
    func isConfigured() -> Bool
    
    func startSampleStream()
    func stopSampleStream()
}
