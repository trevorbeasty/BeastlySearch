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
        didSet { update() }
    }
    let attributeName: String
    let name: String
    let converter: IntConverter
    let increment: Int
    private(set) var min: Value<Int> = Value(Int.min)
    private(set) var max: Value<Int> = Value(Int.max)
    private(set) var selectedMin: Value<Int?> = Value(nil)
    private(set) var selectedMax: Value<Int?> = Value(nil)
    
    init(attributeName: String, name: String, converter: IntConverter? = nil, increment: Int = 1) {
        self.attributeName = attributeName
        self.name = name
        self.converter = converter ?? { String($0) }
        self.increment = increment
        selectedMin.bind { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.compositor?.didUpdate(weakSelf)
        }
        selectedMax.bind { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.compositor?.didUpdate(weakSelf)
        }
    }
    
    // MARK: - CoreDataFiltering
    var filter: NSPredicate? {
        var predicates = [NSPredicate]()
        if let selectedMin = selectedMin.value {
            let minPredicate = NSPredicate(format: "%K > %d", argumentArray: [attributeName, selectedMin])
            predicates.append(minPredicate)
        }
        if let selectedMax = selectedMax.value {
            let maxPredicate = NSPredicate(format: "%K < %d", argumentArray: [attributeName, selectedMax])
            predicates.append(maxPredicate)
        }
        guard predicates.count > 0 else { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    // MARK: - QuantSelectable
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
        self.selectedMin.value = value
    }
    
    func selectMax(_ value: Int) {
        self.selectedMax.value = value
    }
    
    // MARK: - Updating
    func update() {
        min.value = fetchMin()
        max.value = fetchMax()
    }
}






