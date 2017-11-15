//
//  CoreDataQualBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataQualBuilder<T>: CoreDataFiltering, QualSelectable, CoreDataGeneralTextSearchable, Updating where T: NSManagedObject {
    weak var compositor: CoreDataFilterCompositor<T>? {
        willSet { if compositor != nil { fatalError() } }
        didSet { update() }
    }
    let attributeName: String
    let name: String
    let includeInGeneralSearch: Bool
    private(set) var values: Value<Set<String>>
    private(set) var selectedValues: Value<Set<String>>
    private(set) var searchText: Value<String?>
    
    init(attributeName: String, name: String, includeInGeneralSearch: Bool = false){
        self.attributeName = attributeName
        self.name = name
        self.includeInGeneralSearch = includeInGeneralSearch
        self.values = Value([])
        self.selectedValues = Value([])
        self.searchText = Value(nil)
        self.selectedValues.bind { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.compositor?.didUpdate(weakSelf)
        }
        self.searchText.bind { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.compositor?.didUpdate(weakSelf)
        }
    }
    
    private func fetchValues() -> Set<String> {
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
    
    // MARK: - Updating
    func update() {
        values.value = fetchValues()
    }
    
    // MARK: - CoreDataFiltering
    var filter: NSPredicate? {
        let predicates = [selectableFilter, searchableFilter].flatMap { $0 }
        guard predicates.count > 0 else { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    private var selectableFilter: NSPredicate? {
        guard selectedValues.value.count > 0 else { return nil }
        let predicates = selectedValues.value.map { (selectedValue) -> NSPredicate in
            NSPredicate(format: "%K == %@", argumentArray: [attributeName, selectedValue])
        }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    private var searchableFilter: NSPredicate? {
        guard let searchText = searchText.value else { return nil }
        return NSPredicate(format: "%K CONTAINS[c] %@", argumentArray: [attributeName, searchText])
    }
    
    func valueForInstance(_ instance: T) -> String {
        guard let value = instance.value(forKey: self.attributeName) as? String else { fatalError() }
        return value
    }

    
    // MARK: - QualSelectable
    func selectValue(_ value: String) throws {
        guard values.value.contains(value) else { throw QualSelectorError.invalidValue(value) }
        selectedValues.value.insert(value)
    }
    
    func deselectValue(_ value: String) throws {
        guard values.value.contains(value) else { throw QualSelectorError.invalidValue(value) }
        selectedValues.value.remove(value)
    }
    
    func deselectAll() {
        selectedValues.value.removeAll()
    }
    
    func setSearchText(_ text: String?) {
        searchText.value = text
    }
    
    // MARK: - CoreDataGeneralTextSearchable
    func textSearchPredicateFor(text: String) -> NSPredicate? {
        guard includeInGeneralSearch == true else { return nil }
        return NSPredicate(format: "%K CONTAINS[c] %@", argumentArray: [attributeName, text])
    }
}

















