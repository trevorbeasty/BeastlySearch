//
//  CoreDataFilterCompositor.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/7/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataFilterCompositor<T>: Filtering, FilterSelection, PopulationBinding where T: NSManagedObject {
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
    
    var population: [T] {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: entityName)
        return try! context.fetch(request)
    }
    
    // MARK: = FilterSelection
    var quantSelectors: [QuantSelectable] { return quantBuilders as [QuantSelectable] }
    var qualSelectors: [QualSelectable] { return qualBuilders as [QualSelectable] }
    private(set) var generalSearchText: String?
    
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
        let currentFilter = filter
        let filteredPopulation = population.flatMap({ (instance) -> T? in
            if currentFilter(instance) == true { return instance }
            return nil
        })
        activeBindings.forEach { (binding) in
            binding(filteredPopulation)
        }
    }
    
    // MARK: - FilterOutput
    private var builderFilter: (T) -> Bool {
        // capture self weakly?
        return { instance -> Bool in
            if self.quantBuilders.count == 0 && self.qualBuilders.count == 0 { return true }
            var match = true
            self.quantBuilders.forEach({ (quant) in
                if quant.filter(instance) == false { match = false }
            })
            self.qualBuilders.forEach({ (qual) in
                if qual.filter(instance) == false { match = false }
            })
            return match
        }
    }
    
    private var generalSearchTextFilter: (T) -> Bool {
        return { (instance) -> Bool in
            guard let searchText = self.generalSearchText, searchText != "" else {
                return true
            }
            var match = false
            self.qualBuilders.forEach({ (builder) in
                guard builder.includeInGeneralSearch == true else { return }
                let value = builder.valueForInstance(instance)
                if builder.textSearchPredicate(value, searchText) == true { match = true }
            })
            return match
        }
    }
    
    var filter: (T) -> Bool {
        return { (instance) -> Bool in
            return self.builderFilter(instance) && self.generalSearchTextFilter(instance)
        }
    }
}














