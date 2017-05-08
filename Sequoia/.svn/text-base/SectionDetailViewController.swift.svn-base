//
//  SectionDetailViewController.swift
//  Sequoia
//
//  Created by Colin Caufield on 1/1/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit
import SecretKit

class SectionDetailViewController: SGDynamicTableViewController {
    
    override func makeTableData() -> SGTableData {
        
        return (
            SGTableData(
                SGSectionData(
                    SGRowData(cellIdentifier: TEXT_FIELD_CELL_ID,   title: "Name",    modelPath: "name"),
                    SGRowData(cellIdentifier: LABEL_CELL_ID,        title: "Length"),
                    SGRowData(cellIdentifier: LABEL_CELL_ID,        title: "Octave"),
                    SGRowData(cellIdentifier: LABEL_CELL_ID,        title: "Tempo"),
                    SGRowData(cellIdentifier: LABEL_CELL_ID,        title: "Key"),
                    SGRowData(cellIdentifier: LABEL_CELL_ID,        title: "Relative")
                )
            )
        )
    }
}
