//
//  TrackDetailViewController.swift
//  Sequoia
//
//  Created by Colin Caufield on 1/1/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit
import SecretKit

class TrackDetailViewController: SGDynamicTableViewController {
    
    override func makeTableData() -> SGTableData {
        
        return (
            SGTableData(
                SGSectionData(
                    SGRowData(cellIdentifier: TEXT_FIELD_CELL_ID,   title: "Name",          modelPath: "name"),
                    SGRowData(cellIdentifier: TEXT_FIELD_CELL_ID,   title: "Instrument",    modelPath: "instrumentName")
                )
            )
        )
    }
}
