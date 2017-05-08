//
//  Instrument.swift
//  Sequoia
//
//  Created by Colin Caufield on 12/24/14.
//  Copyright (c) 2014 Secret Geometry, Inc. All rights reserved.
//

import Foundation

class Instrument {
    
    var soundBankPlayer = SoundBankPlayer()
    var octaveOffset = 0
    
    class func instrumentNamed(_ name: String) -> Instrument {
        
        let piano = Instrument(soundBankName: "Piano")
        
        switch name {
        case "Bass":
            piano.octaveOffset = -1
        case "Bells":
            piano.octaveOffset = +1
        default:
            break
        }
        
        return piano
    }
    
    init(soundBankName: String) {
        self.soundBankPlayer.setSoundBank(soundBankName)
    }
    
    func playNotes(_ notes: [Note]) {
        
        for note in notes {
            let noteNumber = Int32(60) + Int32(note.value)
            self.soundBankPlayer.queueNote(noteNumber, gain: 1.0)
        }
        
        self.soundBankPlayer.playQueuedNotes()
    }
}
