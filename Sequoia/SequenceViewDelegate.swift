//
//  SequenceViewDelegate.swift
//  Sequoia
//
//  Created by Colin Caufield on 12/5/14.
//  Copyright (c) 2014 Secret Geometry, Inc. All rights reserved.
//

import UIKit

protocol SequenceViewDelegate : class {
    
    func itemWasAdded(_ item: UIView, value: Double, start: Double, length: Double)
    func itemWasRemoved(_ tag: Int)
    func itemWasChanged(_ tag: Int, value: Double, start: Double, length: Double)
}
