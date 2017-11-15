//
//  QuantBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class QuantBuilder<T>: Filtering, QuantSelectable, QuantExpressive {
    // client could potentially derail system by setting delegate after FilterCompositor construction
    weak var delegate: FilterCompositor<T>?
    let name: String
    let keyPath: KeyPath<T,Int>
    let converter: IntConverter
    let increment: Int
    private(set) var min: Value<Int>
    private(set) var max: Value<Int>
    private(set) var selectedMin: Value<Int?> = Value(nil)
    private(set) var selectedMax: Value<Int?> = Value(nil)
    
    init(keyPath: KeyPath<T,Int>, group: QuantGroup<T>, converter: IntConverter? = nil, increment: Int = 1) {
        self.name = group.name
        self.keyPath = keyPath
        self.converter = converter ?? { String($0) }
        self.increment = increment
        self.min = Value(group.min)
        self.max = Value(group.max)
        selectedMin.bind { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.didUpdate(weakSelf)
        }
        selectedMax.bind { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.didUpdate(weakSelf)
        }
    }
    
    convenience init(keyPath: KeyPath<T,Int>, name: String, population: [T], converter: IntConverter? = nil, increment: Int = 1) {
        let values = QuantBuilder.valuesFor(keyPath: keyPath, population: population)
        let group = QuantGroup<T>(name: name, min: values.0, max: values.1)
        self.init(keyPath: keyPath, group: group, converter: converter, increment: increment)
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
            if let max = self.selectedMax.value {
                match = match && value < max
            }
            if let min = self.selectedMin.value {
                match = match && value > min
            }
            return match
        }
    }
    
    // MARK: - QuantSelectable
    func selectMin(_ value: Int) {
        selectedMin.value = value
    }
    
    func selectMax(_ value: Int) {
        selectedMax.value = value
    }
}






