//
//  CoreDataMacroBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/13/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataMacroBuilder<T>: MacroSelectable, CoreDataFiltering, CoreDataSorting where T: NSManagedObject {
    let name: String
    let detail: String?
    let filter: NSPredicate?
    let sorters: [NSSortDescriptor]
    weak var compositor: CoreDataFilterCompositor<T>? {
        willSet { if compositor != nil { fatalError() } }
    }
    
    init(name: String, detail: String?, filter: NSPredicate?, sorters: [NSSortDescriptor]) {
        self.name = name
        self.detail = detail
        self.filter = filter
        self.sorters = sorters
    }
    
    func select() {
        compositor?.didSelectMacroBuilder(self)
    }
}
