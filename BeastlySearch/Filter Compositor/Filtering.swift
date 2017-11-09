//
//  Filtering.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

protocol Filtering {
    associatedtype T
    var filter: (T) -> Bool { get }
}
