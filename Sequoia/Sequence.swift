//
//  Sequence.swift
//  Sequoia
//
//  Created by Colin Caufield on 12/13/14.
//  Copyright (c) 2014 Secret Geometry, Inc. All rights reserved.
//

import Foundation
import CoreData

class Sequence: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var notes: NSSet
    @NSManaged var file: SequenceFile

}
