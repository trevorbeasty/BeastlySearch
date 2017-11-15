//
//  FilterCompositorClient.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import UIKit

class FilterCompositorClient {
    
    static func usedCarExample() -> UIViewController {

        return ClientUtilites.exampleWith(title: "Non-interactive FilterCompositor", description: "Example construction and client interaction") {
            // population
            let cars = SISCar.allUsedCars()
            SISCar.printCars(cars, title: "All cars")
            
            // builders & compositor
            let mileage = QuantBuilder(keyPath: \SISCar.mileage, name: "Mileage", population: cars)
            let brand = QualBuilder(keyPath: \SISCar.make, name: "Brand", population: cars, includeInGeneralSearch: false)
            let model = QualBuilder(keyPath: \SISCar.model, name: "Model", population: cars, includeInGeneralSearch: true)
            let cheapest = SortBuilder<SISCar>(name: "Cheapest", sorter: { (car0, car1) -> Bool in
                return car0.price < car1.price
            })
            let brandSort = SortBuilder<SISCar>(name: "Brand", sorter: { (car0, car1) -> Bool in
                return car0.make < car1.make
            })
            let mostExpensive = SortBuilder<SISCar>(name: "Most Expensive", sorter: { (car0, car1) -> Bool in
                return car0.price > car1.price
            })
            let allUsedFilterSort = FilterSort<SISCar>(
                filter: { (car) -> Bool in return true },
                sorter: { (car0, car1) -> Bool in return car0.price > car1.price})
            let allUsedMacro = MacroBuilder(name: "All Used Cars", filterSort: allUsedFilterSort)
            let filterCompositor = FilterCompositor.compositorFor(quant: [mileage], qual: [brand, model], sort: [cheapest, brandSort], macro: [allUsedMacro], defaultSort: mostExpensive)
            
            // binding
            filterCompositor.filterSort.bind({ (filterSort) in
                let compositedCars = filterSort.resultForPopulation(cars)
                SISCar.printCars(compositedCars, title: "Composited cars")
            })
            
            brand.selectedValues.bind({ (brands) in
                print("\n\nselected brands: \(brands)\n\n")
            })
            
            // filter selection
            mileage.selectMax(100000)
            filterCompositor.setGeneralSearchText("i")
            do {
                try brand.selectValue("Ford")
                try brand.selectValue("Honda")
            }
            catch {
                print(error)
            }
            
            cheapest.select()
            brandSort.select()
            
            allUsedMacro.select()
            
            return UIViewController()
        }
        
    }
    
}
