//
//  CoreDataFiltering.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataFiltering {
    var filter: NSPredicate? { get }
}
