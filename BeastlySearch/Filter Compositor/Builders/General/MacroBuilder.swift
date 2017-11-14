//
//  MacroBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class MacroBuilder<T>: MacroSelectable, Filtering, OptionalSorting {
    let name: String
    let detail: String?
    private let filterSort: FilterSort<T>
    weak var compositor: FilterCompositor<T>? {
        willSet { if compositor != nil { fatalError() } }
    }
    
    init(name: String, detail: String? = nil, filterSort: FilterSort<T>) {
        self.name = name
        self.detail = detail
        self.filterSort = filterSort
    }
    
    var filter: (T) -> Bool {
        return filterSort.filter
    }
    var sorter: (((T), (T)) -> Bool)? {
        return filterSort.sorter
    }
    
    func select() {
        compositor?.didSelectMacroBuilder(self)
    }
}
