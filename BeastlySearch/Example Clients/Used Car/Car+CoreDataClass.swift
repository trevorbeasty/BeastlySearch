//
//  Car+CoreDataClass.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/7/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Car)
public class Car: NSManagedObject {

    static func requestForCar(_ car: SISCar) -> NSFetchRequest<Car> {
        let request: NSFetchRequest<Car> = Car.fetchRequest()
        let idPredicate = NSPredicate(format: "%K == %d", argumentArray: ["id", car.id])
        request.predicate = idPredicate
        return request
    }
    
    func configureFromCar(_ car: SISCar) {
        self.year = car.year
        self.make = car.make
        self.model = car.model
        self.mileage = Int32(car.mileage)
        self.price = Int32(car.price)
        self.id = Int32(car.id)
    }
    
}
