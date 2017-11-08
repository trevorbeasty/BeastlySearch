//
//  CoreDataQuantBuilder.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

class CoreDataQuantBuilder<T>: QuantSelectable where T: NSManagedObject {
    // one context should be shared by all builders and held in the filter compositor
    let context: NSManagedObjectContext
    let entityName: String
    let attributeName: String
    let name: String
    
    init(context: NSManagedObjectContext, entityName: String, attributeName: String, name: String) {
        self.context = context
        self.entityName = entityName
        self.attributeName = attributeName
        self.name = name
    }
    
    private(set) var selectedMin: Int?
    private(set) var selectedMax: Int?
    
    var min: Int {
        var value = Int.max
        population.forEach({ instance in
            guard let currentValue = instance.value(forKey: attributeName) as? Int else { fatalError() }
            if currentValue < value { value = currentValue }
        })
        return value
    }
    
    var max: Int {
        var value = Int.min
        population.forEach({ instance in
            guard let currentValue = instance.value(forKey: attributeName) as? Int else { fatalError() }
            if currentValue > value { value = currentValue }
        })
        return value
    }
    
    private var population: [T] {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: entityName)
        return try! context.fetch(request)
    }
    
    func selectMin(_ value: Int) {
        self.selectedMin = value
    }
    
    func selectMax(_ value: Int) {
        self.selectedMax = value
    }
}
