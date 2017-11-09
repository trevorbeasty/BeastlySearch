//
//  CoreDataFilterCompositor.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/7/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataFilterCompositor<T>: CoreDataFiltering, FilterSelection, PopulationBinding where T: NSManagedObject {
    let context: NSManagedObjectContext
    let entityName: String
    let quantBuilders: [CoreDataQuantBuilder<T>]
    let qualBuilders: [CoreDataQualBuilder<T>]
    
    private init(context: NSManagedObjectContext, entityName: String, quantBuilders: [CoreDataQuantBuilder<T>], qualBuilders: [CoreDataQualBuilder<T>]) {
        self.context = context
        self.entityName = entityName
        self.quantBuilders = quantBuilders
        self.qualBuilders = qualBuilders
    }
    
    static func compositorWith(context: NSManagedObjectContext, entityName: String, quants: [CoreDataQuantBuilder<T>], quals: [CoreDataQualBuilder<T>]) -> CoreDataFilterCompositor {
        let compositor = CoreDataFilterCompositor(context: context, entityName: entityName, quantBuilders: quants, qualBuilders: quals)
        quants.forEach { (quant) in
            quant.compositor = compositor
        }
        quals.forEach { (qual) in
            qual.compositor = compositor
        }
        return compositor
    }
    
    private func request(forPredicate predicate: NSPredicate? = nil) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: entityName)
        if let predicate = predicate {
            request.predicate = predicate
        }
        return request
    }
    
    var population: [T] {
        return try! context.fetch(request())
    }
    
    // MARK: - FilterSelection
    var quantSelectors: [QuantSelectable] { return quantBuilders as [QuantSelectable] }
    var qualSelectors: [QualSelectable] { return qualBuilders as [QualSelectable] }
    private(set) var generalSearchText: String? {
        didSet { executeBindings() }
    }
    
    func setGeneralSearchText(_ text: String?) {
        generalSearchText = text
    }
    
    // MARK: - Population Binding
    var activeBindings: [([T]) -> Void] = []
    
    func bind(_ binding: @escaping ((([T])) -> Void)) {
        activeBindings.append(binding)
    }
    
    func removeBinding(atIndex index: Int) throws -> ((([T])) -> Void) {
        return activeBindings.remove(at: index)
    }
    
    func removeAllBindings() {
        activeBindings.removeAll()
    }
    
    func didUpdate(_ builder: CoreDataQuantBuilder<T>) {
        executeBindings()
    }
    
    func didUpdate(_ builder: CoreDataQualBuilder<T>) {
        executeBindings()
    }
    
    private func executeBindings() {
        let bindingRequest = request(forPredicate: filter)
        let filteredPopulation: [T] = try! context.fetch(bindingRequest)
        activeBindings.forEach { (binding) in
            binding(filteredPopulation)
        }
    }
    
    // MARK: - CoreDataFiltering
    var filter: NSPredicate? {
        let predicates = [builderPredicate, generalSearchTextPredicate].flatMap({ $0 })
        guard predicates.count > 0 else { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    private var coreDataFilters: [CoreDataFiltering] {
        var filters = [CoreDataFiltering]()
        filters.append(contentsOf: quantBuilders as [CoreDataFiltering])
        filters.append(contentsOf: qualBuilders as [CoreDataFiltering])
        return filters
    }
    
    private var builderPredicate: NSPredicate? {
        let predicates = coreDataFilters.flatMap { (filter) -> NSPredicate? in
            filter.filter
        }
        guard predicates.count > 0 else { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    private var generalSearchTextPredicate: NSPredicate? {
        guard let searchText = generalSearchText else { return nil }
        let filters = qualBuilders as [CoreDataGeneralTextSearchable]
        let predicates = filters.flatMap({ $0.textSearchPredicateFor(text: searchText) })
        guard predicates.count > 0 else { return nil }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
}














