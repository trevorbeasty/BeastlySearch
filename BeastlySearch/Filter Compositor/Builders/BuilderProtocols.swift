//
//  BuilderProtocols.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

protocol Filtering {
    associatedtype T
    var filter: (T) -> Bool { get }
}

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

// (baseString, searchText) -> Bool
typealias TextSearchPredicate = (String, String) -> Bool

protocol QualSelectable {
    var name: String { get }
    var values: Set<String> { get }
    var selectedValues: Set<String> { get }
    var searchText: String? { get }
    var textSearchPredicate: TextSearchPredicate { get }
    var includeInGeneralSearch: Bool { get }
    func selectValue(_ value: String) throws
    func deselectValue(_ value: String) throws
    func deselectAll()
    func setSearchText(_ text: String?)
}

