//
//  CoreDataQuantBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataQuantBuilder<T>: Filtering, QuantSelectable, QuantExpressive where T: NSManagedObject {
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
    
    // MARK: - Filtering
    var filter: (T) -> Bool {
        return { instance -> Bool in
            guard let value = instance.value(forKey: self.attributeName) as? Int else { fatalError() }
            var match = true
            if let max = self.selectedMax {
                match = match && value < max
            }
            if let min = self.selectedMin {
                match = match && value > min
            }
            return match
        }
    }
    
    // MARK: - QuantSelectable
    var min: Int {
        var value = Int.max
        population.forEach({ instance in
            let currentValue = valueForInstance(instance)
            if currentValue < value { value = currentValue }
        })
        return value
    }
    
    var max: Int {
        var value = Int.min
        population.forEach({ instance in
            let currentValue = valueForInstance(instance)
            if currentValue > value { value = currentValue }
        })
        return value
    }
    
    func valueForInstance(_ instance: T) -> Int {
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
}
