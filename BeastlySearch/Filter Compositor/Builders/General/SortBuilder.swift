//
//  SortBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class SortBuilder<T>: Sorting, SortSelectable {
    let name: String
    let sorter: (T, T) -> Bool
    weak var compositor: FilterCompositor<T>? {
        willSet { if compositor != nil { fatalError() } }
    }
    
    init(name: String, sorter: @escaping (T, T) -> Bool) {
        self.name = name
        self.sorter = sorter
    }
    
    func select() {
        compositor?.didSelectSortBuilder(self)
    }
}
