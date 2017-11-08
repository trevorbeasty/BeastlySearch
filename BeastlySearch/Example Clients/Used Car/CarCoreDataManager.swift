//
//  CarCoreDataManager.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/7/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation
import CoreData

enum CarCoreDataManagerError: Error {
    case duplicateObjects(AnyClass, Any)
}

protocol CarCoreDataManagerProtocol {
    var context: NSManagedObjectContext { get }
    func saveCar(_ car: SISCar) throws
}

class CarCoreDataManager: CarCoreDataManagerProtocol {
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SISCar")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext { return persistentContainer.viewContext }
    
    func saveCar(_ car: SISCar) throws {
        let carRequest = Car.requestForCar(car)
        let results = try context.fetch(carRequest)
        guard results.count < 2 else {
            throw CarCoreDataManagerError.duplicateObjects(Car.self, car.id)
        }
        let managedCar: Car = (results.first ?? NSEntityDescription.insertNewObject(forEntityName: "Car", into: context)) as! Car
        managedCar.configureFromCar(car)
        try context.save()
    }
    
}















