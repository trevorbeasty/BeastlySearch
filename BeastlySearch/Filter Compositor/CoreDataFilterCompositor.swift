//
//  CoreDataFilterCompositor.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/7/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataFilterCompositor<T>: CoreDataFiltering, CoreDataSorting, FilterSelection, SortSelection where T: NSManagedObject {
    let context: NSManagedObjectContext
    let entityName: String
    let quantBuilders: [CoreDataQuantBuilder<T>]
    let qualBuilders: [CoreDataQualBuilder<T>]
    let sortBuilders: [CoreDataSortBuilder<T>]
    let defaultSortBuilder: CoreDataSortBuilder<T>
    let compositedPopulation = Value<[T]>()
    
    // MARK: - Construction
    private init(context: NSManagedObjectContext, entityName: String, quantBuilders: [CoreDataQuantBuilder<T>], qualBuilders: [CoreDataQualBuilder<T>], sortBuilders: [CoreDataSortBuilder<T>] = [], defaultSortBuilder: CoreDataSortBuilder<T>) {
        self.context = context
        self.entityName = entityName
        self.quantBuilders = quantBuilders
        self.qualBuilders = qualBuilders
        self.sortBuilders = sortBuilders
        self.defaultSortBuilder = defaultSortBuilder
        self.sorters = defaultSortBuilder.sorters
    }
    
    static func compositorWith(context: NSManagedObjectContext, entityName: String, quants: [CoreDataQuantBuilder<T>], quals: [CoreDataQualBuilder<T>], sortBuilders: [CoreDataSortBuilder<T>] = [], defaultSortBuilder: CoreDataSortBuilder<T>) -> CoreDataFilterCompositor {
        let compositor = CoreDataFilterCompositor(context: context, entityName: entityName, quantBuilders: quants, qualBuilders: quals, sortBuilders: sortBuilders, defaultSortBuilder: defaultSortBuilder)
        quants.forEach { (quant) in quant.compositor = compositor }
        quals.forEach { (qual) in qual.compositor = compositor }
        sortBuilders.forEach({ $0.compositor = compositor })
        return compositor
    }
    
    private func updateCompositedPopulation() {
        let bindingRequest = request(forPredicate: filter, sortDescriptors: sorters)
        let filteredPopulation: [T] = try! context.fetch(bindingRequest)
        compositedPopulation.value = filteredPopulation
    }
    
    private func request(forPredicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: entityName)
        if let predicate = predicate {
            request.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            request.sortDescriptors = sortDescriptors
        }
        return request
    }
    
    var population: [T] {
        return try! context.fetch(request())
    }
    
    func didUpdate(_ builder: CoreDataQuantBuilder<T>) {
        updateCompositedPopulation()
    }
    
    func didUpdate(_ builder: CoreDataQualBuilder<T>) {
        updateCompositedPopulation()
    }
    
    func didSelectSortBuilder(_ builder: CoreDataSortBuilder<T>) {
        self.sorters = builder.sorters
        updateCompositedPopulation()
    }
    
    // MARK: - FilterSelection
    var quantSelectors: [QuantSelectable] { return quantBuilders as [QuantSelectable] }
    var qualSelectors: [QualSelectable] { return qualBuilders as [QualSelectable] }
    private(set) var generalSearchText: String? {
        didSet { updateCompositedPopulation() }
    }
    
    func setGeneralSearchText(_ text: String?) {
        generalSearchText = text
    }
    
    // MARK: - SortSelection
    var sortSelectors: [SortSelectable] { return sortBuilders }
    
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
        guard let searchText = generalSearchText, searchText != "" else { return nil }
        let filters = qualBuilders as [CoreDataGeneralTextSearchable]
        let predicates = filters.flatMap({ $0.textSearchPredicateFor(text: searchText) })
        guard predicates.count > 0 else { return nil }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    // MARK: - CoreDataSorting
    private(set) var sorters: [NSSortDescriptor]
}














