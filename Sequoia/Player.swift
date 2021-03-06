//
//  Player.swift
//  Sequoia
//
//  Created by Colin Caufield on 12/24/14.
//  Copyright (c) 2014 Secret Geometry, Inc. All rights reserved.
//

import Foundation
import CoreData

let PlayerStartedNotification = "PlayerStartedNotification"
let PlayerPausedNotification = "PlayerPausedNotification"
let PlayerStoppedNotification = "PlayerStoppedNotification"
let PlayerPositionChangedNotification = "PlayerPositionChangedNotification"

@objc class Player: NSObject {
    
    //var song : Song?
    var sequence: Sequence?
    //var trackInstruments = [Instrument]()
    var instrument = Instrument.instrumentNamed("Piano")
    var timer: Timer?
    var timeStep = 0
    var timeOffset = Double(0.0)
    var timeInterval = Double(0.1)
    //var lastUpdateTime = Double(0.0)
    
    static var singleton: Player?
    
    static var shared: Player {
        if singleton == nil { singleton = Player() }
        return singleton!
    }
    
    override init() {
        // Nothing
    }
    
    var playing: Bool {
        return self.timer != nil
    }
    
    var paused: Bool {
        return self.timer == nil
    }
    
    func playOrPause(_ sender: AnyObject?) {
        
        if self.paused {
            play(sender)
        } else {
            pause(sender)
        }
    }
    
    @IBAction func play(_ sender: AnyObject?) {
        
        if self.playing {
            return
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(update(_:)), userInfo: nil, repeats: true)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: PlayerStartedNotification), object: self)
    }
    
    @IBAction func pause(_ sender: AnyObject?) {
        
        self.timer?.invalidate()
        self.timer = nil
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: PlayerPausedNotification), object: self)
    }
    
    @IBAction func stop(_ sender: AnyObject?) {
        
        self.timer?.invalidate()
        self.timer = nil
        self.timeStep = 0
        self.timeOffset = 0.0
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: PlayerStoppedNotification), object: self)
    }
    
    func update(_ sender: AnyObject?) {
        
        print("Playing [\(self.timeOffset)]")
        
        let notes = notesFrom(self.timeOffset, end: self.timeOffset + self.timeInterval)
        self.instrument.playNotes(notes)
        
        self.timeStep += 1
        self.timeOffset = Double(self.timeStep) * self.timeInterval
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: PlayerPositionChangedNotification), object: self)
    }
    
    func playNotes(_ notes: [Note]) {
        self.instrument.playNotes(notes)
    }
    
    func notesFrom(_ from: Double, end: Double) -> [Note] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        request.predicate = NSPredicate(format: "(sequence = %@) && (startTime >= %lf) && (startTime < %lf)", sequence!, from, end)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        
        var possibleNotes: [AnyObject]?
        do {
            possibleNotes = try AppData.shared.context!.fetch(request)
        } catch {
            possibleNotes = nil
        }
        
        if let notes = possibleNotes {
            return notes as! [Note]
        }
        
        return []
    }
}
