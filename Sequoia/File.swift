//
//  File.swift
//  Sequoia
//
//  Created by Colin Caufield on 12/15/14.
//  Copyright (c) 2014 Secret Geometry, Inc. All rights reserved.
//

import Foundation
import CoreData

class File: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var ordering: Int64
    @NSManaged var folder: Folder?

}
