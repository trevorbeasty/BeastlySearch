//
//  CoreDataClient.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/7/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class CoreDataClient {
    
    static func carExample() {
        let coreDataManager: CarCoreDataManager = CarCoreDataManager()
        let cars = SISCar.allUsedCars()
        cars.forEach { (car) in
            do { try coreDataManager.saveCar(car) }
            catch { print(error) }
        }
        
        let price = CoreDataQuantBuilder(context: coreDataManager.context, entityName: "Car", attributeName: "price", name: "Price")
        price.summarize()
    }
    
}
