//
//  AppData.swift
//  Sequoia
//
//  Created by Colin Caufield on 4/1/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit
import CoreData
import SecretKit

private var _shared: AppData? = nil

class AppData: SGData {
    
    override class var shared: AppData {
        if _shared == nil {
            _shared = AppData()
        }
        return _shared!
    }
    
    init() {
        super.init(name: "Sequoia", useCloud: false)
        assert(_shared == nil)
        _shared = self
    }
}
