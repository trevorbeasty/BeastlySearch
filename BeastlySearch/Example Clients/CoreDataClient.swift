//
//  CoreDataClient.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/7/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import UIKit

class CoreDataClient {
    
    static func carExample() -> UIViewController {
        
        return ClientUtilites.exampleWith(title: "Non-interactive CoreDataFilterCompositor", description: "Example construction and client interaction") {
            // CoreData setup
            let coreDataManager: CarCoreDataManager = CarCoreDataManager()
            let cars = SISCar.allUsedCars()
            cars.forEach { (car) in
                do { try coreDataManager.saveCar(car) }
                catch { print(error) }
            }
            
            let price = CoreDataQuantBuilder<Car>(attributeName: "price", name: "Price")
            let brand = CoreDataQualBuilder<Car>(attributeName: "make", name: "Brand", includeInGeneralSearch: true)
            let model = CoreDataQualBuilder<Car>(attributeName: "model", name: "Model", includeInGeneralSearch: true)
            let compositor = CoreDataFilterCompositor<Car>.compositorWith(context: coreDataManager.context, entityName: "Car", quants: [price], quals: [brand, model])
            
            // print
            price.summarize()
            brand.summarize()
            
            Car.printCars(compositor.population, title: "All Cars")
            
            // bind
            compositor.compositedPopulation.bind { (composited) in
                guard let composited = composited else { return }
                Car.printCars(composited, title: "Composited Cars")
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
            
            compositor.setGeneralSearchText("n")
            
            return UIViewController()
        }

    }
    
}
