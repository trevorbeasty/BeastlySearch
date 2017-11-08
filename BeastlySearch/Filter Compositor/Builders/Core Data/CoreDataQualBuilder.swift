//
//  CoreDataQualBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataQualBuilder<T>: Filtering, QualSelectable where T: NSManagedObject {
    weak var compositor: CoreDataFilterCompositor<T>? {
        willSet { if compositor != nil { fatalError() } }
    }
    let attributeName: String
    let name: String
    let textSearchPredicate: TextSearchPredicate
    let includeInGeneralSearch: Bool
    
    init(attributeName: String, name: String, textSearchPredicate: @escaping TextSearchPredicate = CoreDataQualBuilder.defaultTextSeachPredicate, includeInGeneralSearch: Bool = false){
        self.attributeName = attributeName
        self.name = name
        self.textSearchPredicate = textSearchPredicate
        self.includeInGeneralSearch = includeInGeneralSearch
    }
    
    static var defaultTextSeachPredicate: TextSearchPredicate {
        return { baseString, searchText in
            return baseString.contains(searchText)
        }
    }
    
    var values: Set<String> {
        var values = Set<String>()
        population.forEach { (instance) in
            guard let value = instance.value(forKey: attributeName) as? String else { fatalError() }
            values.insert(value)
        }
        return values
    }
    
    private var population: [T] {
        guard let compositor = compositor else { fatalError() }
        return compositor.population
    }
    
    // MARK: - Filtering
    var filter: (T) -> Bool {
        return { (instance) -> Bool in
            return self.selectableFilter(instance) && self.searchableFilter(instance)
        }
    }
    
    private var selectableFilter: (T) -> Bool {
        // should self be captured weakly?
        return { instance -> Bool in
            let value = self.valueForInstance(instance)
            if self.selectedValues.count == 0 { return true }
            return self.selectedValues.contains(value)
        }
    }
    
    private var searchableFilter: (T) -> Bool {
        return { (instance) -> Bool in
            guard let searchText = self.searchText, searchText != "" else {
                return true
            }
            let value = self.valueForInstance(instance)
            return self.textSearchPredicate(value, searchText)
        }
    }
    
    func valueForInstance(_ instance: T) -> String {
        guard let value = instance.value(forKey: self.attributeName) as? String else { fatalError() }
        return value
    }

    
    // MARK: - QualSelectable
    private(set) var selectedValues = Set<String>() {
        didSet { compositor?.didUpdate(self) }
    }
    private(set) var searchText: String? {
        didSet { compositor?.didUpdate(self) }
    }
    
    func selectValue(_ value: String) throws {
        guard values.contains(value) else { throw QualSelectorError.invalidValue(value) }
        selectedValues.insert(value)
    }
    
    func deselectValue(_ value: String) throws {
        guard values.contains(value) else { throw QualSelectorError.invalidValue(value) }
        selectedValues.remove(value)
    }
    
    func deselectAll() {
        selectedValues.removeAll()
    }
    
    func setSearchText(_ text: String?) {
        searchText = text
    }
}
