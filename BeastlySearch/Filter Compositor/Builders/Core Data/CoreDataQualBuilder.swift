//
//  CoreDataQualBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataQualBuilder<T>: QualSelectable where T: NSManagedObject {
    let context: NSManagedObjectContext
    let entityName: String
    let attributeName: String
    let name: String
    let textSearchPredicate: TextSearchPredicate
    let includeInGeneralSearch: Bool
    
    init(context: NSManagedObjectContext, entityName: String, attributeName: String, name: String, textSearchPredicate: @escaping TextSearchPredicate = CoreDataQualBuilder.defaultTextSeachPredicate, includeInGeneralSearch: Bool = false) {
        self.context = context
        self.entityName = entityName
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
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: entityName)
        return try! context.fetch(request)
    }
    
    // MARK: - QualSelectable
    private(set) var selectedValues = Set<String>()
    private(set) var searchText: String?
    
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
