//
//  CoreDataFilterCompositor.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/7/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataFilterCompositor<T>: CoreDataFiltering, CoreDataSorting, PopulationReactive, FilterSelection, SortSelection, MacroSelection, Updating where T: NSManagedObject {
    let context: NSManagedObjectContext
    let entityName: String
    let quantBuilders: [CoreDataQuantBuilder<T>]
    let qualBuilders: [CoreDataQualBuilder<T>]
    let sortBuilders: [CoreDataSortBuilder<T>]
    let defaultSortBuilder: CoreDataSortBuilder<T>
    let macroBuilders: [CoreDataMacroBuilder<T>]
    let compositedPopulation: Value<[T]>
    
    // MARK: - Construction
    private init(context: NSManagedObjectContext, entityName: String, quantBuilders: [CoreDataQuantBuilder<T>], qualBuilders: [CoreDataQualBuilder<T>], sortBuilders: [CoreDataSortBuilder<T>] = [], defaultSortBuilder: CoreDataSortBuilder<T>, macroBuilders: [CoreDataMacroBuilder<T>] = [], generalSearchText: String? = nil) {
        self.context = context
        self.entityName = entityName
        self.quantBuilders = quantBuilders
        self.qualBuilders = qualBuilders
        self.sortBuilders = sortBuilders
        self.defaultSortBuilder = defaultSortBuilder
        self.macroBuilders = macroBuilders
        let filter = CoreDataFilterCompositor.filterFor(quant: quantBuilders, qual: qualBuilders, generalSearchText: generalSearchText)
        sortBuilders.forEach({ $0.deselect() })
        let bindingRequest = CoreDataFilterCompositor.requestFor(entityName: entityName, predicate: filter, sortDescriptors: defaultSortBuilder.sorters)
        let filteredPopulation: [T] = try! context.fetch(bindingRequest)
        self.compositedPopulation = Value(filteredPopulation)
    }
    
    static func compositorWith(context: NSManagedObjectContext, entityName: String, quants: [CoreDataQuantBuilder<T>], quals: [CoreDataQualBuilder<T>], sortBuilders: [CoreDataSortBuilder<T>] = [], defaultSortBuilder: CoreDataSortBuilder<T>, macroBuilders: [CoreDataMacroBuilder<T>] = [], generalSearchText: String? = nil) -> CoreDataFilterCompositor {
        let compositor = CoreDataFilterCompositor(context: context, entityName: entityName, quantBuilders: quants, qualBuilders: quals, sortBuilders: sortBuilders, defaultSortBuilder: defaultSortBuilder, macroBuilders: macroBuilders, generalSearchText: generalSearchText)
        quants.forEach { (quant) in quant.compositor = compositor }
        quals.forEach { (qual) in qual.compositor = compositor }
        sortBuilders.forEach({ $0.compositor = compositor })
        macroBuilders.forEach({ $0.compositor = compositor })
        return compositor
    }
    
    private func updateCompositedPopulation() {
        let bindingRequest = CoreDataFilterCompositor.requestFor(entityName: entityName, predicate: filter, sortDescriptors: sorters)
        let filteredPopulation: [T] = try! context.fetch(bindingRequest)
        compositedPopulation.value = filteredPopulation
    }
    
    private static func requestFor(entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchRequest<T> {
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
        let request = CoreDataFilterCompositor.requestFor(entityName: entityName)
        return try! context.fetch(request)
    }
    
    func didUpdate(_ builder: CoreDataQuantBuilder<T>) {
        updateCompositedPopulation()
    }
    
    func didUpdate(_ builder: CoreDataQualBuilder<T>) {
        updateCompositedPopulation()
    }
    
    func selectSortBuilder(_ builder: CoreDataSortBuilder<T>) {
        if builder == selectedSortBuilder { return }
        selectedSortBuilder?.isSelected.value = false
        builder.isSelected.value = true
        selectedSortBuilder = builder
        updateCompositedPopulation()
    }
    
    func deselectSortBuilder(_ builder: CoreDataSortBuilder<T>) {
        if builder == selectedSortBuilder {
            builder.isSelected.value = false
            selectedSortBuilder = nil
            updateCompositedPopulation()
        }
    }
    
    func didSelectMacroBuilder(_ builder: CoreDataMacroBuilder<T>) {
        let bindingRequest = CoreDataFilterCompositor.requestFor(entityName: entityName, predicate: builder.filter, sortDescriptors: builder.sorters)
        let filteredPopulation: [T] = try! context.fetch(bindingRequest)
        compositedPopulation.value = filteredPopulation
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
        return CoreDataFilterCompositor.filterFor(quant: quantBuilders, qual: qualBuilders, generalSearchText: generalSearchText)
    }
    
    private static func filterFor(quant: [CoreDataQuantBuilder<T>], qual: [CoreDataQualBuilder<T>], generalSearchText: String?) -> NSPredicate? {
        let filters = coreDataFiltersFor(quant: quant, qual: qual)
        let predicates = [
            builderPredicateFor(filters: filters),
            generalSearchTextPredicateFor(qual: qual, generalSearchText: generalSearchText)
        ].flatMap({ $0 })
        guard predicates.count > 0 else { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    private static func coreDataFiltersFor(quant: [CoreDataQuantBuilder<T>], qual: [CoreDataQualBuilder<T>]) -> [CoreDataFiltering] {
        var filters = [CoreDataFiltering]()
        filters.append(contentsOf: quant as [CoreDataFiltering])
        filters.append(contentsOf: qual as [CoreDataFiltering])
        return filters
    }
    
    private static func builderPredicateFor(filters: [CoreDataFiltering]) -> NSPredicate? {
        let predicates = filters.flatMap { (filter) -> NSPredicate? in
            filter.filter
        }
        guard predicates.count > 0 else { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    private static func generalSearchTextPredicateFor(qual: [CoreDataQualBuilder<T>], generalSearchText: String?) -> NSPredicate? {
        guard let searchText = generalSearchText, searchText != "" else { return nil }
        let filters = qual as [CoreDataGeneralTextSearchable]
        let predicates = filters.flatMap({ $0.textSearchPredicateFor(text: searchText) })
        guard predicates.count > 0 else { return nil }
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    // MARK: - CoreDataSorting
    private var selectedSortBuilder: CoreDataSortBuilder<T>?
    var sorters: [NSSortDescriptor] {
        return selectedSortBuilder?.sorters ?? defaultSortBuilder.sorters
    }
    
    // MARK: - MacroSelection
    var macroSelectors: [MacroSelectable] { return macroBuilders as [MacroSelectable] }
    
    // MARK: - Updating
    func update() {
        quantBuilders.forEach({ $0.update() })
        qualBuilders.forEach({ $0.update() })
        updateCompositedPopulation()
    }
}














