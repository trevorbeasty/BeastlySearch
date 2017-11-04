//
//  FilterCompositorClient.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

typealias VoidClosure = () -> Void

func exampleWith(title: String, description: String, example: VoidClosure) {
    let dash = String(repeating: "-", count: 10)
    print("\n\n\(dash)\nExample of: \(title)\nDescription: \(description)\n\(dash)")
    example()
    print("\n\(dash)\nEnd of example: \(title)\n\(dash)")
}

class FilterCompositorClient {
    
    static var usedCarExample: VoidClosure {
        return {
            return exampleWith(title: "Title", description: "description") {
                // population
                let cars = SISCar.allUsedCars()
                SISCar.printCars(cars, title: "All cars")
                
                // builders & compositor
                let mileage = QuantBuilder(keyPath: \SISCar.mileage, name: "Mileage", population: cars)
                let brand = QualBuilder(keyPath: \SISCar.make, name: "Brand", population: cars, includeInGeneralSearch: false)
                let model = QualBuilder(keyPath: \SISCar.model, name: "Model", population: cars, includeInGeneralSearch: true)
                let filterCompositor = FilterCompositor.compositorFor(quant: [mileage], qual: [brand, model])
                
                // binding
                filterCompositor.bind({ (carFilter) in
                    let filteredCars = cars.filter(carFilter)
                    SISCar.printCars(filteredCars, title: "Filtered cars")
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

            }
        }
    }
    
}