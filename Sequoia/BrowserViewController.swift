//
//  BrowserViewController.swift
//  Sequoia
//
//  Created by Colin Caufield on 11/30/14.
//  Copyright (c) 2014 Secret Geometry, Inc. All rights reserved.
//

import UIKit
import CoreData
import SecretKit

enum BrowseType {
    
    case byFolder
    case byTrack
}

let SECTIONS_FOLDER_NAME = "Sections"
let TRACKS_FOLDER_NAME = "Tracks"

class BrowserViewController: SGCoreDataTableViewController {
    
    // MARK: - Properties
    
    var folder: Folder?
    var browseType = BrowseType.byFolder
    
    // MARK: - Property overrides
    
    override var typeName: String { return "File" }
    
    override var needsBackButton: Bool { return true }
    
    override var allowReordering: Bool { return true }
    
    override var allowInsertion: Bool {
        return !(self.folder is Song)
    }
    
    override var allowEditing: Bool {
        return !(self.folder is Song)
    }
    
    override var sortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "ordering", ascending: true)]
    }
    
    override var fetchPredicate: NSPredicate {
        
        if self.folder == nil {
            return NSPredicate(format: "folder = nil")
        }
        
        if self.browseType == .byFolder {
            return NSPredicate(format: "folder = %@", folder!)
        }
        
        return NSPredicate(format: "track = %@", folder!)
    }
    
    override var cacheName: String? {
        
        if self.folder == nil {
            return "com.secretgeometry.Sequoia.Root"
        }
        
        switch self.browseType {
        case .byFolder:
            return folder!.objectID.description + ".ByFolder"
        case .byTrack:
            return folder!.objectID.description + ".ByTrack"
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = (self.folder == nil) ? "Home" : self.folder!.name
    }
    
    // MARK: - Cells
    
    override func cellIdentifierForObject(_ object: AnyObject) -> String {
        
        switch object {
            
        case is Song:           return "Song"
        case is Section:        return "Section"
        case is Folder:         return "Folder"
        case is TrackFile:      return "Track"
        case is SequenceFile:   return "Sequence"
            
        default:
            //assertionFailure()
            return "Sequence"
        }
    }
    
    override func configureCell(_ cell: UITableViewCell, withObject object: AnyObject) {
        
        if let file = object as? File {
        
            cell.textLabel!.text = file.name
            
            //playButtonView = PlayButtonView()
            //playButtonView.type = 0
            //cell.accessoryView = playButtonView
            
            if file is Folder {
                cell.imageView?.image = UIImage(named: "UIBarButtonSystemItemOrganize")
            }
        }
    }
    
    // MARK: - Objects
    
    override func canEditObject(_ object: AnyObject) -> Bool {
        return true
    }
    
    override func didSelectObject(_ object: AnyObject, new: Bool) {
        
        switch object {
            
        case is SequenceFile:
            self.performSegue(withIdentifier: "showSequence", sender: self)
            
        case is TrackFile:
            self.performSegue(withIdentifier: "showTrackDetails", sender: self)
            
        case let folder as Folder:
            let newController = self.storyboard?.instantiateViewController(withIdentifier: "Browser") as! BrowserViewController
            newController.folder = folder
            self.navigationController?.pushViewController(newController, animated: true)
            
        default:
            break
        }
    }
    
    // MARK: - Segues
    
    @IBAction func segueToDetails(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showSectionDetails", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showSequence" || segue.identifier == "showTrackDetails" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                if let file = fetchController.object(at: indexPath) as? File {
                    
                    switch file {
                        
                    case let sequenceFile as SequenceFile:
                        
                        let sequenceController = segue.destination as! SequenceViewController
                        sequenceController.sequence = sequenceFile.sequence
                        
                    case let trackFile as TrackFile:
                        
                        let trackController = segue.destination as! TrackDetailViewController
                        trackController.object = trackFile.track
                        
                    default:
                        assertionFailure()
                    }
                }
            }
            
            return
        }
        
        if segue.identifier == "showSectionDetails" {
            let detailController = segue.destination as! SectionDetailViewController
            detailController.object = self.folder
            return
        }
    }
    
    // MARK: - Insertions
    
    @IBAction override func add(sender: AnyObject?) {
        self.showInsertionActionSheet(sender)
    }
    
    @IBAction func showInsertionActionSheet(_ sender: AnyObject?) {
        
        let canInsertSong = canCreateSong()
        let canInsertFolder = canCreateFolder()
        let canInsertSection = canCreateSection()
        let canInsertTrack = canCreateTrack()
        let canInsertSequence = canCreateSequence()
        
        var count = 0
        if canInsertSong { count += 1 }
        if canInsertFolder { count += 1 }
        if canInsertSection { count += 1 }
        if canInsertTrack { count += 1 }
        if canInsertSequence { count += 1 }
        
        if count == 0 { return }
        
        if count == 1 {
            if canInsertSong { insertNewSong() }
            if canInsertFolder { insertNewFolder() }
            if canInsertSection { insertNewSection() }
            if canInsertTrack { insertNewTrack() }
            if canInsertSequence { insertNewSequence() }
            return
        }
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if canInsertSong {
            sheet.addAction(UIAlertAction(title: "Song", style: .default, handler: {
                (action: UIAlertAction) in self.insertNewSong()
            }))
        }
        
        if canInsertFolder {
            sheet.addAction(UIAlertAction(title: "Folder", style: .default, handler: {
                (action: UIAlertAction) in self.insertNewFolder()
            }))
        }
        
        if canInsertSection {
            sheet.addAction(UIAlertAction(title: "Section", style: .default, handler: {
                (action: UIAlertAction) in self.insertNewSection()
            }))
        }
        
        if canInsertTrack {
            sheet.addAction(UIAlertAction(title: "Track", style: .default, handler: {
                (action: UIAlertAction) in self.insertNewTrack()
            }))
        }
        
        if canInsertSequence {
            sheet.addAction(UIAlertAction(title: "Sequence", style: .default, handler: {
                (action: UIAlertAction) in self.insertNewSequence()
            }))
        }
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func canCreateFolder() -> Bool {
        return (parentOfType() as Song?) == nil
    }
    
    func canCreateSong() -> Bool {
        return (parentOfType() as Song?) == nil
    }
    
    func canCreateSection() -> Bool {
        return isInSongFolder(SECTIONS_FOLDER_NAME)
    }
    
    func canCreateTrack() -> Bool {
        return isInSongFolder(TRACKS_FOLDER_NAME)
    }
    
    func canCreateSequence() -> Bool {
        return (parentOfType() as Section?) != nil
    }
    
    func parentOfType<Type>() -> Type? {
        
        var parent = self.folder
        
        while true {
            
            if parent == nil {
                return nil
            } else if parent is Type {
                return parent as! Type?
            }
            
            parent = parent?.folder
        }
    }
    
    func isInSongFolder(_ folderName: String) -> Bool {
        
        var parent = self.folder
        
        while true {
            
            if parent == nil {
                return false
            }
            
            if parent!.name == folderName && parent!.folder is Song {
                return true
            }
            
            parent = parent?.folder
        }
    }
    
    func nextAvailableName(_ desiredName: String) -> String {
        
        var name = ""
        var index = 1
        var existingFile : File? = nil
        
        repeat {
            let suffix = (index == 1) ? "" : " " + String(index)
            name = desiredName + suffix
            existingFile = fileNamed(name)
            index += 1
        }
            while existingFile != nil
        
        return name
    }
    
    func insertNewSong() {
        
        checkOrdering()
        
        let name = nextAvailableName("Song")
        let song = NSEntityDescription.insertNewObject(forEntityName: "Song", into: self.context) as! Song
        
        let sections = NSEntityDescription.insertNewObject(forEntityName: "Folder", into: self.context) as! Folder
        
        let tracks = NSEntityDescription.insertNewObject(forEntityName: "Folder", into: self.context) as! Folder
        
        song.name = name
        song.ordering = Int64(fileCount())
        
        if self.folder != nil {
            song.folder = self.folder!
        }
        
        let files = song.files as! NSMutableSet
        files.add(sections)
        files.add(tracks)
        
        sections.name = SECTIONS_FOLDER_NAME
        sections.folder = song
        sections.ordering = 0
        
        tracks.name = TRACKS_FOLDER_NAME
        tracks.folder = song
        tracks.ordering = 1
        
        self.saveObjects()
    }
    
    func insertNewFolder() {
        
        checkOrdering()
        
        let name = nextAvailableName("Folder")
        let folder = NSEntityDescription.insertNewObject(forEntityName: "Folder", into: self.context) as! Folder
        
        folder.name = name
        folder.ordering = Int64(fileCount())
        
        if self.folder != nil {
            folder.folder = self.folder!
        }
        
        self.saveObjects()
    }
    
    func insertNewSection() {
        
        checkOrdering()
        
        let name = nextAvailableName("Section")
        let section = NSEntityDescription.insertNewObject(forEntityName: "Section", into: self.context) as! Section
        
        section.name = name
        section.ordering = Int64(fileCount())
        
        if self.folder != nil {
            section.folder = folder!
        }
        
        self.saveObjects()
    }
    
    func insertNewTrack() {
        
        checkOrdering()
        
        let name = nextAvailableName("Track")
        let file = NSEntityDescription.insertNewObject(forEntityName: "TrackFile", into: self.context) as! TrackFile
        let track = NSEntityDescription.insertNewObject(forEntityName: "Track", into: self.context) as! Track
        
        file.name = name
        file.track = track
        file.ordering = Int64(fileCount())
        
        if self.folder != nil {
            file.folder = folder!
        }
        
        track.name = name
        track.file = file
        
        self.saveObjects()
    }
    
    func insertNewSequence() {
        
        checkOrdering()
        
        let name = nextAvailableName("Sequence")
        let file = NSEntityDescription.insertNewObject(forEntityName: "SequenceFile", into: self.context) as! SequenceFile
        let sequence = NSEntityDescription.insertNewObject(forEntityName: "Sequence", into: self.context) as! Sequence
        
        file.name = name
        file.sequence = sequence
        file.ordering = Int64(fileCount())
        
        if self.folder != nil {
            file.folder = folder!
        }
        
        sequence.name = name
        sequence.file = file
        
        self.saveObjects()
    }
    
    func fileNamed(_ name: String) -> File? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "File")
        
        if self.folder == nil {
            request.predicate = NSPredicate(format: "(folder = nil) && (name = %@)", name)
        } else {
            request.predicate = NSPredicate(format: "(folder = %@) && (name = %@)", folder!, name)
        }
        
        var possibleFiles: [AnyObject]?
        do {
            possibleFiles = try self.context.fetch(request)
        } catch  {
            possibleFiles = nil
        }
        
        if let files = possibleFiles {
            if files.count > 0 {
                return files[0] as? File
            }
        }
        
        return nil
    }
    
    func fileCount() -> Int {
        
        if let files = self.fetchController.fetchedObjects {
            return files.count
        }
        
        return 0
    }
}

