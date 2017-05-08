//
//  SequenceViewController.swift
//  Sequoia
//
//  Created by Colin Caufield on 11/30/14.
//  Copyright (c) 2014 Secret Geometry, Inc. All rights reserved.
//

import UIKit
import CoreData
import SecretKit

class SequenceViewController: UIViewController, SequenceViewDelegate {
    
    @IBOutlet var sequenceView: SequenceView!
    var nextFreeTag = 1
    
    var sequence: Sequence? {
        didSet {
            if self.sequenceView != nil {
                configureView()
            }
        }
    }
    
    var backgroundSequence: Sequence? {
        didSet {
            if self.sequenceView != nil {
                configureView()
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return AppData.shared.context!
    }
    
    var player: Player {
        return Player.shared
    }
    
    func configureView() {
        
        self.sequenceView.delegate = self
        
        if let seq = self.sequence {
            
            self.title = seq.name
            
            for note in self.orderedNotes() {
                note.tag = Int64(self.nextFreeTag)
                self.sequenceView.addItem(self.nextFreeTag, value: note.value, start: note.startTime, length: note.duration)
                self.nextFreeTag += 1
            }
        }
        else {
            
            self.title = "Unknown"
        }
        
        AppData.shared.save()
    }
    
    func updatePlayButton() {
        //navigationItem.rightBarButtonItem?.title = (self.timer == nil) ? "Play" : "Pause"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let title = (self.sequence != nil) ? self.sequence!.name : "Unknown"
        self.title = title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateCursor() {
        self.sequenceView.moveCursorView(CGFloat(self.player.timeOffset))
    }
    
    func orderedNotes() -> [Note] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        request.predicate = NSPredicate(format: "sequence = %@", sequence!)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        
        var possibleNotes: [AnyObject]?
        do {
            possibleNotes = try self.context.fetch(request)
        } catch {
            possibleNotes = nil
        }
        
        if let notes = possibleNotes {
            return notes as! [Note]
        }
        
        return []
    }
    
    func noteWithTag(_ tag: Int) -> Note? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        request.predicate = NSPredicate(format: "(sequence = %@) && (tag = %d)", sequence!, tag)
        
        var possibleNotes: [AnyObject]?
        do {
            possibleNotes = try self.context.fetch(request)
        } catch {
            possibleNotes = nil
        }
        
        if let notes = possibleNotes {
            if notes.count > 0 {
                return notes[0] as? Note
            }
        }
        
        return nil
    }
    
    func itemWasAdded(_ item: UIView, value: Double, start: Double, length: Double) {
        
        // Add the note to the model.
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: self.context) as! Note
        
        // Configure the note.
        note.tag = Int64(self.nextFreeTag)
        note.value = value
        note.startTime = start
        note.duration = length
        note.sequence = sequence!
        
        // Configure the sequence.
        let notes = sequence!.notes as! NSMutableSet
        notes.add(note)
        
        // Save the model.
        AppData.shared.save()
        
        // Tag the UI element.
        item.tag = Int(note.tag)
        self.nextFreeTag += 1
        
        // Play the sound.
        self.player.playNotes([note])
    }
    
    func itemWasRemoved(_ tag: Int) {
        
        // Ignore invalid tags (they should be impossible).
        if tag == 0 {
            return
        }
        
        // Remove note from model.
        if let note = noteWithTag(tag) {
            self.context.delete(note)
            AppData.shared.save()
        }
    }
    
    func itemWasChanged(_ tag: Int, value: Double, start: Double, length: Double) {
        
        // Update note in model.
        if let note = noteWithTag(tag) {
            note.value = value;
            note.startTime = start
            note.duration = length
            AppData.shared.save()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showSectionDetails" {
            print("SequenceViewController prepareForSegue")
            let detailController = segue.destination as! SectionDetailViewController
            detailController.object = self.sequence
        }
    }
}

