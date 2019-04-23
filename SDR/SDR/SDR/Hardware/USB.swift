//
//  USB.swift
//  SDRDevice
//
//  Created by Davorin Mađarić on 19/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

import Foundation
import LibUSB

// https://github.com/libusb/libusb/blob/master/examples/hotplugtest.c

class USB {
    static let shared = USB()
    
    private let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
    private var usbDeviceHandle: UnsafeMutablePointer<OpaquePointer?>? = nil
    
    private let vendor_id: Int32 = LIBUSB_HOTPLUG_MATCH_ANY
    private let product_id: Int32 = LIBUSB_HOTPLUG_MATCH_ANY
    private let class_id: Int32 = LIBUSB_HOTPLUG_MATCH_ANY
    
    private var deviceArrivedCallbackHandle: libusb_hotplug_callback_handle = 0
    private var deviceLeftCallbackHandle: libusb_hotplug_callback_handle = 0
    
    // MARK: - 
    
    private init() { }
    
    deinit {
        usbExit()
    }
    
    // MARK: - Public
    
    func registerEvents() {
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
    
    // MARK: - USB helpers
    
    private func usbInit() -> Bool {
        let rc = libusb_init(nil)
        if rc < 0 {
            print("failed to initialise libusb: %s", libusb_error_name(rc))
            return false
        }
        
        return true
    }
    
    private func usbCheckCapability() -> Bool {
        let res = libusb_has_capability(LIBUSB_CAP_HAS_HOTPLUG)
        if res != 1 {
            print("Hotplug capabilites are not supported on this platform")
            return false
        }
        
        return true
    }
    
    private func usbRegisterEventDeviceArrived() -> Bool {
        let user_data = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        let rc = libusb_hotplug_register_callback(nil, LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED, LIBUSB_HOTPLUG_NO_FLAGS, vendor_id, product_id, class_id, { (_ ctx: OpaquePointer?, _ device: OpaquePointer?, _ event: libusb_hotplug_event, _ data: UnsafeMutableRawPointer?) -> Int32 in
            
            var deviceDescriptor: UnsafeMutablePointer<libusb_device_descriptor> = UnsafeMutablePointer<libusb_device_descriptor>.allocate(capacity: 255)
            
            let rc = libusb_get_device_descriptor(device, deviceDescriptor)
            if (LIBUSB_SUCCESS.rawValue != rc) {
                print(stderr, "Error getting device descriptor")
            }
            
            print("Device attach: %04x:%04x", deviceDescriptor.pointee.idVendor, deviceDescriptor.pointee.idProduct)
            
            let selfUSB = Unmanaged<USB>.fromOpaque(data!).takeUnretainedValue()
            
            let res = libusb_open(device, selfUSB.usbDeviceHandle)
            
            return 0
        }, user_data, &deviceArrivedCallbackHandle)
        
        if LIBUSB_SUCCESS != libusb_error(rawValue: rc) {
            print("Error registering callback LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED")
            return false
        }
        
        return true
    }
    
    private func usbRegisterEventDeviceLeft() -> Bool {
        let user_data = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        let rc = libusb_hotplug_register_callback(nil, LIBUSB_HOTPLUG_EVENT_DEVICE_LEFT, LIBUSB_HOTPLUG_NO_FLAGS, vendor_id, product_id, class_id, { (_ ctx: OpaquePointer?, _ device: OpaquePointer?, _ event: libusb_hotplug_event, _ data: UnsafeMutableRawPointer?) -> Int32 in
            
            print("Device detached\n")
            
            let selfUSB = Unmanaged<USB>.fromOpaque(data!).takeUnretainedValue()
            
            libusb_close(selfUSB.usbDeviceHandle?.pointee)
            
            
            
            return 0
        }, user_data, &deviceLeftCallbackHandle)
        
        if LIBUSB_SUCCESS != libusb_error(rawValue: rc) {
            print(stderr, "Error registering callback LIBUSB_HOTPLUG_EVENT_DEVICE_LEFT")
            return false
        }
        
        return true
    }
    
    private func usbHandleEvents() {
        print("usbHandleEvents")
        
        let rc = libusb_handle_events(nil)
        if rc < 0 {
            print("libusb_handle_events() failed: %s\n", libusb_error_name(rc))
        }
    }
    
    private func usbExit() {
        if usbDeviceHandle != nil {
            libusb_close(usbDeviceHandle?.pointee)
        }
        
        libusb_exit(nil)
    }
}
