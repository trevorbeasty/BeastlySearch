//
//  FilterSort.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

struct FilterSort<T> {
    let filter: (T) -> Bool
    let sorter: ((T, T) -> Bool)?
    
    func resultForPopulation(_ population: [T]) -> [T] {
        let filtered = population.filter(filter)
        if let sorter = sorter {
            return filtered.sorted(by: sorter)
        }
        return filtered
    }
}
