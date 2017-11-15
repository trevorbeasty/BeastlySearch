//
//  CoreDataSortBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataSorter {
    let attributeName: String
    let ascending: Bool
}

class CoreDataSortBuilder<T>: CoreDataSorting, SortSelectable where T: NSManagedObject {
    let name: String
    private(set) var isSelected: Value<Bool> = Value(false)
    private let coreDataSorters: [CoreDataSorter]
    weak var compositor: CoreDataFilterCompositor<T>?
    var sorters: [NSSortDescriptor] {
        return coreDataSorters.map({ (sorter) -> NSSortDescriptor in
            return NSSortDescriptor(key: sorter.attributeName, ascending: sorter.ascending)
        })
    }
    
    init(name: String, sorters: [CoreDataSorter]) {
        self.name = name
        self.coreDataSorters = sorters
    }
    
    func select() {
        compositor?.selectSortBuilder(self)
    }
    
    func deselect() {
        compositor?.deselectSortBuilder(self)
    }
}

extension CoreDataSortBuilder: Equatable {
    static func ==(lhs: CoreDataSortBuilder<T>, rhs: CoreDataSortBuilder<T>) -> Bool {
        return lhs.name == rhs.name
    }
}
