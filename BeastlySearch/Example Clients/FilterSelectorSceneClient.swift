//
//  FilterSelectorSceneClient.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class FilterSelectorSceneClient {
    
    // must be persisted, otherwise will deallocate following setup and bindings will not be called
    static var carsFilterCompositor: FilterCompositor<SISCar>?
    
    static var usedCarsFilterSelectorScene: FilterSelectorViewController {
        let cars = SISCar.allUsedCars()
        let mileage = QuantBuilder(keyPath: \SISCar.mileage, name: "Mileage", population: cars)
        let brand = QualBuilder(keyPath: \SISCar.make, name: "Brand", population: cars, includeInGeneralSearch: true)
        let model = QualBuilder(keyPath: \SISCar.model, name: "Model", population: cars, includeInGeneralSearch: true)
        let filterCompositor = FilterCompositor.compositorFor(quant: [mileage], qual: [brand, model])
        let selectors: [FilterSelectorType] = [
            FilterSelectorType.quant(mileage),
            FilterSelectorType.qual(brand),
            FilterSelectorType.qual(model)
        ]
        let filterSelectorVC = FilterSelectorRouter.buildFilterRouterModuleFor(selectors: selectors)
        
        // prints all cars initially, and filtered cars every time the filter updates
        SISCar.printCars(cars, title: "All cars")
        filterCompositor.bind { (carFilter) in
            let filteredCars = cars.filter(carFilter)
            SISCar.printCars(filteredCars, title: "Filtered cars")
        }
        
        carsFilterCompositor = filterCompositor
        return filterSelectorVC
    }
    
}
