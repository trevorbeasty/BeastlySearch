//
//  Sorting.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

protocol Sorting {
    associatedtype T
    var sorter: (T, T) -> Bool { get }
}
