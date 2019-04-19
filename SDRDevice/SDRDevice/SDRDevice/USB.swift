//
//  USB.swift
//  SDRDevice
//
//  Created by Davorin Mađarić on 19/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation
import LibUSB

class USB {
    static let shared = USB()
    
    private let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
    private var handle: UnsafeMutablePointer<OpaquePointer?>? = nil
    
    private var hp: [libusb_hotplug_callback_handle] = []
    private let vendor_id: Int32 = LIBUSB_HOTPLUG_MATCH_ANY
    private let product_id: Int32 = LIBUSB_HOTPLUG_MATCH_ANY
    private let class_id: Int32 = LIBUSB_HOTPLUG_MATCH_ANY
    
    // MARK: - USB init
    
    private init() {
        usbInit()
        usbCheckCapability()
        usbRegisterEventDeviceArrived()
        usbRegisterEventDeviceLeft()
        
        dispatchQueue.async { [unowned self] in
            while true {
                self.usbHandleEvents()
            }
        }
    }
    
    deinit {
        usbExit()
    }
    
    // MARK: - USB functions
    
    private func usbInit() -> Bool {
        let rc = libusb_init(handle)
        if rc < 0 {
            print("failed to initialise libusb: %s", libusb_error_name(rc))
            return false
        }
        
        return true
    }
    
    private func usbCheckCapability() -> Bool {
        let res = libusb_has_capability(LIBUSB_CAP_HAS_HOTPLUG)
        if res <= 0 {
            print("Hotplug capabilites are not supported on this platform")
            return false
        }
        
        return true
    }
    
    private func usbRegisterEventDeviceArrived() -> Bool {
        let user_data: UnsafeMutableRawPointer? = nil
        
        let rc = libusb_hotplug_register_callback(nil, LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED, LIBUSB_HOTPLUG_NO_FLAGS, vendor_id, product_id, class_id, { (_ ctx: OpaquePointer?, _ device: OpaquePointer?, _ event: libusb_hotplug_event, _ data: UnsafeMutableRawPointer?) -> Int32 in
            
            
            
            
            return 0
        }, user_data, &hp[0])
        
        if LIBUSB_SUCCESS != libusb_error(rawValue: rc) {
            print("Error registering callback LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED")
            return false
        }
        
        return true
    }
    
    private func usbRegisterEventDeviceLeft() -> Bool {
        let user_data: UnsafeMutableRawPointer? = nil
        
        let rc = libusb_hotplug_register_callback(nil, LIBUSB_HOTPLUG_EVENT_DEVICE_LEFT, LIBUSB_HOTPLUG_NO_FLAGS, vendor_id, product_id, class_id, { (_ ctx: OpaquePointer?, _ device: OpaquePointer?, _ event: libusb_hotplug_event, _ data: UnsafeMutableRawPointer?) -> Int32 in
            
            
            
            
            return 0
        }, user_data, &hp[1])
        
        if LIBUSB_SUCCESS != libusb_error(rawValue: rc) {
            print(stderr, "Error registering callback LIBUSB_HOTPLUG_EVENT_DEVICE_LEFT")
            return false
        }
        
        return true
    }
    
    private func usbHandleEvents() {
        let rc = libusb_handle_events(handle?.pointee)
        if rc < 0 {
            print("libusb_handle_events() failed: %s\n", libusb_error_name(rc))
        }
    }
    
    private func usbExit() {
        if handle != nil {
            libusb_close(handle?.pointee)
        }
        
        libusb_exit(nil)
    }
}
