//
//  Selectable.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

// MARK: - Quant
typealias IntConverter = (Int) -> String
protocol QuantExpressive {
    var converter: IntConverter { get }
    var increment: Int { get }
}

protocol QuantSelectable {
    var name: String { get }
    var min: Value<Int> { get }
    var max: Value<Int> { get }
    var selectedMin: Value<Int?> { get }
    var selectedMax: Value<Int?> { get }
    func selectMin(_ value: Int)
    func selectMax(_ value: Int)
}

extension QuantSelectable {
    func summarize() {
        print("name: \(name), min: \(min), max: \(max)")
    }
}

// MARK: - Qual
protocol QualSelectable {
    var name: String { get }
    var values: Value<Set<String>> { get }
    var selectedValues: Value<Set<String>> { get }
    var searchText: Value<String?> { get }
    func selectValue(_ value: String) throws
    func deselectValue(_ value: String) throws
    func deselectAll()
    func setSearchText(_ text: String?)
}

extension QualSelectable {
    func summarize() {
        print("name: \(name), values: \(values)")
    }
}

// MARK: - Sort
protocol SortSelectable {
    var name: String { get }
    var isSelected: Bool { get }
    func select()
    func deselect()
}

// MARK: - Macro
protocol MacroSelectable {
    var name: String { get }
    var detail: String? { get }
    func select()
}























