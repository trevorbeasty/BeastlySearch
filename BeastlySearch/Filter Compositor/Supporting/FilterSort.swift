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
    let sort: ((T, T) -> Bool)?
    
    func resultForPopulation(_ population: [T]) -> [T] {
        let filtered = population.filter(filter)
        if let sort = sort {
            return filtered.sorted(by: sort)
        }
        return filtered
    }
}
