import Foundation

// TODO: Divide SDRDevice to public and internal protocols
// SDRDevice -> public
// SDRDeviceInternal -> private

// TODO: Change func getters to readonly properties
// TODO: Changable properties to readonly observers

public protocol SDRDevice: class {
    var name: String { get }
    var rawSamples: ObservableEvent<[UInt8]> { get }
    
    func minimumFrequency() -> Int
    func maximumFrequency() -> Int
    
    func sampleRate() -> Int
    func sampleRate(rate: Int)
    func sampleRateList() -> [Int]
    
    func tunedFrequency() -> Int
    func tunedFrequency(frequency: Int)
    
    func frequencyCorrection() -> Int
    func frequencyCorrection(correction: Int)
    
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
