//
//  QuantBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class QuantBuilder<T>: Filtering, QuantSelectable {
    // client could potentially derail system by setting delegate after FilterCompositor construction
    var delegate: FilterCompositor<T>?
    let keyPath: KeyPath<T,Int>
    let group: QuantGroup<T>
    var selectedMin: Int? {
        didSet { delegate?.didUpdate(self) }
    }
    var selectedMax: Int? {
        didSet { delegate?.didUpdate(self) }
    }
    
    init(keyPath: KeyPath<T,Int>, group: QuantGroup<T>) {
        self.keyPath = keyPath
        self.group = group
    }
    
    convenience init(keyPath: KeyPath<T,Int>, name: String, population: [T]) {
        let values = QuantBuilder.valuesFor(keyPath: keyPath, population: population)
        let group = QuantGroup<T>(name: name, min: values.0, max: values.1)
        self.init(keyPath: keyPath, group: group)
    }
    
    private static func valuesFor(keyPath: KeyPath<T,Int>, population: [T]) -> (Int, Int) {
        var minValue = Int.max
        var maxValue = Int.min
        population.forEach { (instance) in
            let value = instance[keyPath: keyPath]
            minValue = value < minValue ? value : minValue
            maxValue = value > maxValue ? value : maxValue
        }
        return (minValue, maxValue)
    }
    
    // MARK: - Filtering
    var filter: (T) -> Bool {
        // should self be captured weakly?
        return { instance -> Bool in
            let value = instance[keyPath: self.keyPath]
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
    var name: String {
        return group.name
    }
    var min: Int {
        return group.min
    }
    var max: Int {
        return group.max
    }
    
    func selectMin(_ value: Int) {
        selectedMin = value
    }
    
    func selectMax(_ value: Int) {
        selectedMax = value
    }
}
