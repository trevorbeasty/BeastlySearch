//
//  SortSelection.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

protocol SortSelection: class {
    var sortSelectors: [SortSelectable] { get }
}
