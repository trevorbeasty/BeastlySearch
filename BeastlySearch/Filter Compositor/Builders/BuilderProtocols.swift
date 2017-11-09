//
//  BuilderProtocols.swift
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
    var min: Int { get }
    var max: Int { get }
    var selectedMin: Int? { get }
    var selectedMax: Int? { get }
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
    var values: Set<String> { get }
    var selectedValues: Set<String> { get }
    var searchText: String? { get }
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
    func select()
}























