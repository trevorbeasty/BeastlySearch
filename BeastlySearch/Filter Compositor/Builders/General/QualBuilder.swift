//
//  QualBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class QualBuilder<T>: Filtering, QualSelectable, GeneralTextSearchable {
    weak var delegate: FilterCompositor<T>?
    let keyPath: KeyPath<T,String>
    let group: QualGroup<T>
    private(set) var values: Value<Set<String>>
    private(set) var selectedValues: Value<Set<String>>
    private(set) var searchText: Value<String?>
    let textSearchPredicate: TextSearchPredicate
    let includeInGeneralSearch: Bool
    
    init(keyPath: KeyPath<T,String>, group: QualGroup<T>, textSearchPredicate: TextSearchPredicate? = nil, includeInGeneralSearch: Bool = false) {
        self.keyPath = keyPath
        self.group = group
        self.textSearchPredicate = textSearchPredicate ?? QualBuilder.defaultTextSeachPredicate
        self.includeInGeneralSearch = includeInGeneralSearch
        self.values = Value(group.values)
        self.selectedValues = Value([])
        self.searchText = Value(nil)
        selectedValues.bind({ [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.didUpdate(weakSelf)
        })
        searchText.bind({ [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.didUpdate(weakSelf)
        })
    }
    
    convenience init(keyPath: KeyPath<T,String>, name: String, population: [T], textSearchPredicate: TextSearchPredicate? = nil, includeInGeneralSearch: Bool = false) {
        let values = QualBuilder.valuesFor(keyPath: keyPath, population: population)
        let group = QualGroup<T>(name: name, values: values)
        self.init(keyPath: keyPath, group: group, textSearchPredicate: textSearchPredicate, includeInGeneralSearch: includeInGeneralSearch)
    }
    
    private static func valuesFor(keyPath: KeyPath<T,String>, population: [T]) -> Set<String> {
        var values = Set<String>()
        population.forEach { (instance) in
            values.insert(instance[keyPath: keyPath])
        }
        return values
    }
    
    static var defaultTextSeachPredicate: TextSearchPredicate {
        return { baseString, searchText in
            return baseString.contains(searchText)
        }
    }
    
    // MARK: - Filtering
    private var selectableFilter: (T) -> Bool {
        // should self be captured weakly?
        return { instance -> Bool in
            let value = instance[keyPath: self.keyPath]
            if self.selectedValues.value.count == 0 { return true }
            return self.selectedValues.value.contains(value)
        }
    }
    
    private var searchableFilter: (T) -> Bool {
        return { (instance) -> Bool in
            guard let searchText = self.searchText.value, searchText != "" else {
                return true
            }
            return self.textSearchPredicate(instance[keyPath: self.keyPath], searchText)
        }
    }
    
    var filter: (T) -> Bool {
        return { (instance) -> Bool in
            return self.selectableFilter(instance) && self.searchableFilter(instance)
        }
    }
    
    // MARK: - QualSelectable
    var name: String { return group.name }
    
    func selectValue(_ value: String) throws {
        guard group.values.contains(value) else {
            throw QualSelectorError.invalidValue(value)
        }
        selectedValues.value.insert(value)
    }
    
    func deselectValue(_ value: String) throws {
        guard group.values.contains(value) else {
            throw QualSelectorError.invalidValue(value)
        }
        selectedValues.value.remove(value)
    }
    
    func deselectAll() {
        selectedValues.value.removeAll()
    }
    
    func setSearchText(_ text: String?) {
        searchText.value = text
    }
}
