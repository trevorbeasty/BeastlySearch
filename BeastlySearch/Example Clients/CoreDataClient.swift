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
        
        let price = CoreDataQuantBuilder(attributeName: "price", name: "Price")
        let brand = CoreDataQualBuilder(attributeName: "make", name: "Brand")
        let compositor = CoreDataFilterCompositor.compositorWith(context: coreDataManager.context, entityName: "Car", quants: [price], quals: [brand])
        
        price.summarize()
        brand.summarize()
        
        // bind
        compositor.bind { (filteredPopulation) in
            print("\n\n\n")
            filteredPopulation.forEach({ print($0) })
        }
        
        // select
        price.selectMax(10000)
        do {
            try brand.selectValue("Ford")
            try brand.selectValue("Honda")
        }
        catch {
            print(error)
        }
    }
    
}
