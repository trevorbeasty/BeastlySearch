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
                let cars = SISCar.allUsedCars()
                let mileage = QuantBuilder(keyPath: \SISCar.mileage, name: "Mileage", population: cars)
                let brand = QualBuilder(keyPath: \SISCar.make, name: "Brand", population: cars, includeInGeneralSearch: false)
                let model = QualBuilder(keyPath: \SISCar.model, name: "Model", population: cars, includeInGeneralSearch: true)
                let filterCompositor = FilterCompositor.compositorFor(quant: [mileage], qual: [brand, model])
                
                mileage.selectMax(100000)
                filterCompositor.setGeneralSearchText("i")
                do {
                    try brand.selectValue("Ford")
                    try brand.selectValue("Honda")
                }
                catch {
                    print(error)
                }
                let filteredCars = cars.filter(filterCompositor.filter)
    
                SISCar.printCars(cars, title: "All cars")
                if filteredCars.count == 0 { print("No search results") }
                else { SISCar.printCars(filteredCars, title: "Filtered cars:") }
            }
        }
    }
    
}
