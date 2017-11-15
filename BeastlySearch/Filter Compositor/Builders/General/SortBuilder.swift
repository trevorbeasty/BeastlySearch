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
    private(set) var isSelected: Value<Bool> = Value(false)
    let sorter: (T, T) -> Bool
    weak var compositor: FilterCompositor<T>? {
        willSet { if compositor != nil { fatalError() } }
    }
    
    init(name: String, sorter: @escaping (T, T) -> Bool) {
        self.name = name
        self.sorter = sorter
    }
    
    func select() {
        compositor?.selectSortBuilder(self)
    }
    
    func deselect() {
        compositor?.deselectSortBuilder(self)
    }
}

extension SortBuilder: Equatable {
    static func ==(lhs: SortBuilder<T>, rhs: SortBuilder<T>) -> Bool {
        return lhs.name == rhs.name
    }
}
