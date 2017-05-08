//
//  AppDelegate.swift
//  Sequoia
//
//  Created by Colin Caufield on 11/30/14.
//  Copyright (c) 2014 Secret Geometry, Inc. All rights reserved.
//

import UIKit
import SecretKit

// Testing these CocoaPods
import MIKMIDI
import OSCKit
//import Peak

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Force early creation.
        let _ = AppData.shared
        let _ = Player.shared
        
        self.testMIKMIDI()
        
        self.testOSCKit()
        
        //self.testPeak()
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        AppData.shared.save()
    }
    
    func testMIKMIDI() {
        
        print("Testing MIKMIDI")
        
        let manager = MIKMIDIDeviceManager.shared()
        
        print("Available Devices")
        for device in manager.availableDevices {
            print(device.description)
        }
        
        print("Virtual Sources")
        for device in manager.virtualSources {
            print(device.description)
        }
        
        print("Virtual Destinations")
        for device in manager.virtualDestinations {
            print(device.description)
        }
    }
    
    func testOSCKit() {
        
        print("Testing OSCKit")
        
        let client = OSCClient()
        
        let message1 = OSCMessage.to("/hello", with: [1, "cool", 0.5])!
        let message2 = OSCMessage.to("/world", with: ["crazy", 876])!
        
        client.sendMessages([message1, message2], to: "udp://localhost:8000")
    }
    
    /*
    func testPeak() {
        
        print("Testing Peak")
        
        let buffer = Buffer()
        print(buffer)
    }
    */
}

