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
            let mostExpensiveSorter = CoreDataSorter(attributeName: "price", ascending: false)
            let mostExpensive = CoreDataSortBuilder<Car>(name: "Most Expensive", sorters: [mostExpensiveSorter])
            let newestSorter = CoreDataSorter(attributeName: "year", ascending: false)
            let cheapestSorter = CoreDataSorter(attributeName: "price", ascending: true)
            let newest = CoreDataSortBuilder<Car>(name: "Newest", sorters: [newestSorter, cheapestSorter])
            let newHonda = CoreDataMacroBuilder<Car>(
                name: "New Honda's",
                detail: "Honda's sorted by age",
                filter: NSPredicate(format: "%K == %@", argumentArray: ["make", "Honda"]),
                sorters: [NSSortDescriptor(key: "year", ascending: false)])
            let compositor = CoreDataFilterCompositor<Car>.compositorWith(context: coreDataManager.context, entityName: "Car", quants: [price], quals: [brand, model], sortBuilders: [newest, mostExpensive], defaultSortBuilder: mostExpensive, macroBuilders: [newHonda])
            
            // print
            price.summarize()
            brand.summarize()
            
            Car.printCars(compositor.population, title: "All Cars")
            
            // bind
            compositor.compositedPopulation.bind { (composited) in
                Car.printCars(composited, title: "Composited Cars")
            }
            
            price.selectedMax.bind({ (max) in
                guard let max = max else { return }
                print("\n\nselected max: \(max)\n\n")
            })
            
            brand.selectedValues.bind({ (brands) in
                print("\n\nselected brands: \(brands)\n\n")
            })
            
            newest.isSelected.bind({ (isSelected) in
                print("\n\nnewest is selected: \(isSelected)\n\n")
            })
            
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
            newest.select()

            newHonda.select()
            
            newest.select()
            mostExpensive.select()
            
            return UIViewController()
        }

    }
    
}
