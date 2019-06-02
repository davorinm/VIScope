//
//  RTLSDR.swift
//  waveSDR
//
//  Copyright © 2017 GetOffMyHack. All rights reserved.
//

import Foundation
import LibRTLSDR

final class RTLSDR: SDRDevice {
    let rawSamples: ObservableEvent<[UInt8]> = ObservableEvent()
    
    
    // MARK: - Type Properties

    //------------------------------------------------------------
    //
    // Private Type Properties
    //
    //------------------------------------------------------------
    
    private static let _rtlsdrCount: Int = {
        
        let rtlsdrCount = Int(rtlsdr_get_device_count())
        return rtlsdrCount
        
    }()

    private static let _deviceArray: [RTLSDR] = {
        
        var rtlsdrArray: [RTLSDR] = []
        
        for i in 0..<_rtlsdrCount {
            let device = RTLSDR(i)
            device.initDevice()
            rtlsdrArray.append(device)
        }
        
        return rtlsdrArray
        
    }()
    
    private static let _sampleRates:    [Int] = [960000, 2400000]
    
    private static let gainModeAuto:    Int32  = 0
    private static let gainModeManual:  Int32  = 1

    
    //--------------------------------------------------------------------------
    //
    // MARK: - type Methods
    //
    //--------------------------------------------------------------------------
    
    class func deviceCount() -> Int {
        return _rtlsdrCount
    }
    
    class func deviceList() -> [SDRDevice] {
        return _deviceArray
    }

    
    //------------------------------------------------------------
    //
    // MARK: - Public Instance Properties
    //
    //------------------------------------------------------------
    
    let usbName:            String
    let usbManufacture:     String
    let usbProduct:         String
    let usbSerial:          String
    let name:               String
    
    var tuner:              String = ""
    var isInitalized:       Bool   = false
    
    var description:   String {
        get {
            return usbName
        }
    }
    
    //------------------------------------------------------------
    //
    // MARK: - Private Instance Properties
    //
    //------------------------------------------------------------
    
    private let asyncReadQueue:         DispatchQueue
    private let asyncReadQueueLabel:    String = "RTLSDR.asyncReadQueue"
    
    private var librtlsdrPointer:       OpaquePointer?  = nil
    private var librtlsdrIndex:         UInt32          = 0
    
    private var bufferSize:             Int          = 16384 * 2 // TODO: Check buffer size
    
    private var sampleBuffer:           [UInt8]
    
    private var _isConfigured:          Bool    = false
    
    var sampleRate: Int = 2400000 {
        didSet {
            if(self.isOpen() == true) {
                let rate = UInt32(self.sampleRate)
                rtlsdr_set_sample_rate(self.librtlsdrPointer, rate)
            }
        }
    }
    
    var tunedFrequency: Int = 100600000 {
        didSet {
//            print("Set freq: \(self._tunedFrequency) - \(self.description)")
            if(self.isOpen() == true) {
                let frequency = UInt32(self.tunedFrequency)
                rtlsdr_set_center_freq(self.librtlsdrPointer, frequency)
            }
        }
    }
    
    var frequencyCorrection: Int = 0 {
        didSet {
            if(self.isOpen() == true) {
                let correction = Int32(self.frequencyCorrection)
                rtlsdr_set_freq_correction(self.librtlsdrPointer, correction)
            }
        }
    }
    
    private var _tunerGainList:         [Int]   = []
    
    private var _tunerAutoGain:         Bool    = true {
        didSet {
            if(self.isOpen() == true) {
                if(self._tunerAutoGain == true) {
                    rtlsdr_set_tuner_gain_mode(self.librtlsdrPointer, RTLSDR.gainModeAuto)
                } else {
                    rtlsdr_set_tuner_gain_mode(self.librtlsdrPointer, RTLSDR.gainModeManual)
                    rtlsdr_set_tuner_gain(self.librtlsdrPointer, Int32(self._tunerGain))
                }
            }
        }
    }
    
    private var _tunerGain:             Int     = 0 {
        didSet {
            if(self.isOpen() == true) {
                let gain = Int32(self._tunerGain)
                rtlsdr_set_tuner_gain(self.librtlsdrPointer, gain)                
            }
        }
    }

    
    //------------------------------------------------------------
    //
    // MARK: - Public Type Methods
    //
    //------------------------------------------------------------

    //
    
    //--------------------------------------------------------------------------
    //
    // MARK: - SDRDeviceProtocol
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    //
    // minimumFrequency()
    //
    // return minimum supported frequency
    //
    //--------------------------------------------------------------------------
    
    // hardcoded for the R820T tuner
    let minimumFrequency: Int = 24000000
    
    // hardcoded for the R820T tuner
    let maximumFrequency: Int = 1766000000
    
    
    
    //--------------------------------------------------------------------------
    //
    // sampleRateList() -> [UInt]
    //
    // retreive list of available sample rates
    //
    //--------------------------------------------------------------------------
    
    func sampleRateList() -> [Int] {
        
        return RTLSDR._sampleRates

    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func tunerGainArray() -> [Int] {
        
        return _tunerGainList
    
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func tunerAutoGain() -> Bool {
        
        return _tunerAutoGain
        
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func tunerAutoGain(auto: Bool) {
        
        self._tunerAutoGain = auto
        
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func tunerGain() -> Int {
        
        return _tunerGain
        
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func tunerGain(gain: Int) {
        
        self._tunerGain = gain
        
    }
    
    //--------------------------------------------------------------------------
    //
    // isOpen() -> Bool
    //
    // is current device opened via librtlsdr
    //
    //--------------------------------------------------------------------------

    func isOpen() -> Bool {

        if(librtlsdrPointer != nil) {
            return true
        } else {
            return false
        }
    }
    
    //--------------------------------------------------------------------------
    //
    // isConfigured() -> Bool
    //
    // is current device opened via librtlsdr
    //
    //--------------------------------------------------------------------------
    
    func isConfigured() -> Bool {
        
        return self._isConfigured
    
    }

    
    //------------------------------------------------------------
    //
    // MARK: - Instance Methods
    //
    //------------------------------------------------------------
    
    func open() {
        
        rtlsdr_open(&librtlsdrPointer, librtlsdrIndex)
        
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func close() {
        
        if(self.isOpen() == true) {
            rtlsdr_close(librtlsdrPointer)
            librtlsdrPointer = nil
        }
        
    }
    
    //--------------------------------------------------------------------------
    //
    // startSamplesStream()
    //
    // A convience method to start streaming (async reading) from RTLSDR
    // device
    //
    //--------------------------------------------------------------------------

    
    func startSampleStream() {
        
        // open device
        if(self.isOpen() == false) {
            self.open()
        }
        
        // initalize device
        if(self.isConfigured() == false) {
            self.initDevice()
        }
        
        // make sure to configure all parameters
        // -- the instance properties all have observers that will
        //    call the needed librtlsdr function to set the parameter
        
        let sr                  = self.sampleRate
        self.sampleRate        = sr
        
        let ppm                 = self.frequencyCorrection
        self.frequencyCorrection        = ppm
        
        let freq                = self.tunedFrequency
        self.tunedFrequency    = freq
        
        let auto = self._tunerAutoGain
        self._tunerAutoGain = auto
        
        // reset buffer
        rtlsdr_reset_buffer(self.librtlsdrPointer)
        
        readAsyncFromDevice()
        
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func stopSampleStream() {
        
        self.cancelAsyncRead()
        self.close()
        
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func cancelAsyncRead() {
        
        if(self.isOpen() == true) {
            rtlsdr_cancel_async(self.librtlsdrPointer)
        }
        
    }
 
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    func readAsyncFromDevice() {
 
        asyncReadQueue.async {
            
            let rtlSdrContext = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            
            
            rtlsdr_read_async(self.librtlsdrPointer, { (buffer: UnsafeMutablePointer<UInt8>?, length: UInt32, ctx: UnsafeMutableRawPointer?) -> Void in
                
                let selfRTLSDR =  Unmanaged<RTLSDR>.fromOpaque(ctx!).takeUnretainedValue()
                
                // get a buffer pointer with length to samples
                let bufferPointer = UnsafeMutableBufferPointer(start: buffer, count: Int(length))
                
                // convert buffer to Swift [UInt8]
                let samples: [UInt8] = Array(bufferPointer)
                
                
                selfRTLSDR.rawSamples.raise(samples)
                
                
            }, rtlSdrContext, UInt32(0), UInt32(self.bufferSize))
        }
    }
    
    // init() is marked private as the only time an object is initalized will
    // be first access to deviceArray from the getDeviceArray() type method
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    private init(_ devID: Int) {
        
        // set devID as index to librtlsdr device
        librtlsdrIndex     = UInt32(devID)
        
        // get the librtlsdr name
        name      = String(cString: UnsafePointer(rtlsdr_get_device_name(librtlsdrIndex)))
        
        // get usb strings from device
        var manf:   [CChar] = [CChar](repeating: 0, count: 255)
        var prod:	[CChar] = [CChar](repeating: 0, count: 255)
        var serial:	[CChar] = [CChar](repeating: 0, count: 255)
        
        rtlsdr_get_device_usb_strings(librtlsdrIndex, &manf, &prod, &serial)
        
        usbManufacture    = String(cString: manf)
        usbProduct        = String(cString: prod)
        usbSerial         = String(cString: serial)
        usbName           = usbManufacture + " " + usbProduct + " SN: " + usbSerial
        
        // TODO: Check name and usbName
        
        // Initalize vars
        
        asyncReadQueue  = DispatchQueue(label: "\(asyncReadQueueLabel).\(devID)")
        sampleBuffer    = [UInt8](repeating: 0, count: bufferSize)
        
        sampleRate = Int(RTLSDR._sampleRates.max()!)

    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    private func initDevice() {
        
        open()
        initDeviceTunerGainList()
        initDeviceTuner()
        self._isConfigured = true
        close()
        
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    private func initDeviceTunerGainList() {
        if(isOpen() == true) {
            
            let tunerGainCount: Int     = Int(rtlsdr_get_tuner_gains(librtlsdrPointer, nil))
            var gainList:       [Int32] = [Int32](repeating: 0, count: tunerGainCount)
            
            rtlsdr_get_tuner_gains(librtlsdrPointer, &gainList)
            
            self._tunerGainList = gainList.map( {
                (gain: Int32) -> Int in
                return Int(gain)
            })
            
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //
    //
    //--------------------------------------------------------------------------

    private func initDeviceTuner() {
        if(isOpen() == true) {
            
            let deviceTunerType: rtlsdr_tuner = rtlsdr_get_tuner_type(librtlsdrPointer)
            
            switch(deviceTunerType.rawValue) {
                
            case (RTLSDR_TUNER_E4000.rawValue):
                tuner = ("Elonics E4000")
                break;
            case (RTLSDR_TUNER_FC0012.rawValue):
                tuner = ("Fitipower FC0012")
                break;
            case (RTLSDR_TUNER_FC0013.rawValue):
                tuner = ("Fitipower FC0013")
                break;
            case (RTLSDR_TUNER_FC2580.rawValue):
                tuner = ("FCI 2580")
                break;
            case (RTLSDR_TUNER_R820T.rawValue):
                tuner = ("Rafael Micro R820T")
                break;
            case (RTLSDR_TUNER_R828D.rawValue):
                tuner = ("Rafael Micro R828D")
                break;
            default:
                tuner = ("Unknown Tuner")
                
            }
        }
    }
    
    
}

