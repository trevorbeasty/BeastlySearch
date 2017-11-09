//
//  CoreDataGeneralTextSearchable.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataGeneralTextSearchable {
    var includeInGeneralSearch: Bool { get }
    func textSearchPredicateFor(text: String) -> NSPredicate?
}
