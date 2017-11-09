//
//  FilterCompositorProtocols.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

// MARK: - Binding
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

protocol CompositorBinding: class {
    associatedtype T
    var activeBindings: [(FilterSort<T>) -> Void] { get }
    func bind(_ binding: @escaping ((FilterSort<T>) -> Void))
    func removeBinding(atIndex index: Int) throws -> (FilterSort<T>) -> Void
    func removeAllBindings()
}

protocol PopulationBinding: class {
    associatedtype T
    var activeBindings: [([T]) -> Void] { get }
    func bind(_ binding: @escaping (([T]) -> Void))
    func removeBinding(atIndex index: Int) throws -> (([T]) -> Void)
    func removeAllBindings()
}

// MARK: - Selection
protocol FilterSelection: class {
    var quantSelectors: [QuantSelectable] { get }
    var qualSelectors: [QualSelectable] { get }
    var generalSearchText: String? { get }
    func setGeneralSearchText(_ text: String?)
}

protocol SortSelection: class {
    var sortSelectors: [SortSelectable] { get }
}
