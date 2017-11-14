//
//  CoreDataQuantBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataQuantBuilder<T>: CoreDataFiltering, QuantSelectable, QuantExpressive, Updating where T: NSManagedObject {
    weak var compositor: CoreDataFilterCompositor<T>? {
        willSet { if compositor != nil { fatalError() } }
    }
    let attributeName: String
    let name: String
    let converter: IntConverter
    let increment: Int
    
    init(attributeName: String, name: String, converter: IntConverter? = nil, increment: Int = 1) {
        self.attributeName = attributeName
        self.name = name
        self.converter = converter ?? { String($0) }
        self.increment = increment
    }
    
    private(set) var selectedMin: Int? {
        didSet { compositor?.didUpdate(self) }
    }
    private(set) var selectedMax: Int? {
        didSet { compositor?.didUpdate(self) }
    }
    
    // MARK: - CoreDataFiltering
    var filter: NSPredicate? {
        var predicates = [NSPredicate]()
        if let selectedMin = selectedMin {
            let minPredicate = NSPredicate(format: "%K > %d", argumentArray: [attributeName, selectedMin])
            predicates.append(minPredicate)
        }
        if let selectedMax = selectedMax {
            let maxPredicate = NSPredicate(format: "%K < %d", argumentArray: [attributeName, selectedMax])
            predicates.append(maxPredicate)
        }
        guard predicates.count > 0 else { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    // MARK: - QuantSelectable
    var min: Int {
        get {
            if _min == nil { _min = fetchMin() }
            return _min!
        }
    }
    private var _min: Int?
    
    var max: Int {
        get {
            if _max == nil { _max = fetchMax() }
            return _max!
        }
    }
    private var _max: Int?
    
    private func fetchMin() -> Int {
        var value = Int.max
        population.forEach({ instance in
            let currentValue = valueForInstance(instance)
            if currentValue < value { value = currentValue }
        })
        return value
    }
    
    private func fetchMax() -> Int {
        var value = Int.min
        population.forEach({ instance in
            let currentValue = valueForInstance(instance)
            if currentValue > value { value = currentValue }
        })
        return value
    }
    
    private func valueForInstance(_ instance: T) -> Int {
        guard let value = instance.value(forKey: self.attributeName) as? Int else { fatalError() }
        return value
    }
    
    private var population: [T] {
        guard let compositor = compositor else { fatalError() }
        return compositor.population
    }
    
    func selectMin(_ value: Int) {
        self.selectedMin = value
    }
    
    func selectMax(_ value: Int) {
        self.selectedMax = value
    }
    
    // MARK: - Updating
    func update() {
        _min = fetchMin()
        _max = fetchMax()
    }
}






