//
//  FilterSelectorSceneClient.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import UIKit

extension Int {
    var commaFormattedString: String {
        guard self != 0 else { return "0" }
        var value = self
        var string = ""
        while value > 0 {
            let currentValue = value % 1000
            value = value / 1000
            var currentString = String(currentValue)
            if value > 0 {
                let zeroesCount = 3 - currentString.characters.count
                let zeroesString = String(repeating: "0", count: zeroesCount)
                currentString = zeroesString + currentString
            }
            string = "," + String(currentString) + string
        }
        if string.characters.count > 3 { string.removeFirst() }
        return string
    }
}

class FilterSelectorSceneClient {
    
    // must be persisted, otherwise will deallocate following setup and bindings will not be called
    private static var carsFilterCompositor: FilterCompositor<SISCar>?
    
    static func usedCarsFilterSelectorScene() -> UIViewController {
        
        return ClientUtilites.exampleWith(title: "Interactive FilterCompositor", description: "Example construction of FilterCompositor / FilterCompositorViewController.  Interact with the view to trigger FilterCompositor bindings", ends: false) {
            let cars = SISCar.allUsedCars()
            let mileageConverter: IntConverter = { value -> String in
                let miles = value == 1 ? "mile" : "miles"
                return "\(value.commaFormattedString) \(miles)"
            }
            let mileage = QuantBuilder(keyPath: \SISCar.mileage, name: "Mileage", population: cars, converter: mileageConverter, increment: 1000)
            let priceConverter: IntConverter = { value -> String in
                return "$\(value.commaFormattedString)"
            }
            let price = QuantBuilder(keyPath: \SISCar.price, name: "Price", population: cars, converter: priceConverter, increment: 100)
            let brand = QualBuilder(keyPath: \SISCar.make, name: "Brand", population: cars, includeInGeneralSearch: true)
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
            let filterCompositor = FilterCompositor.compositorFor(quant: [price, mileage], qual: [brand, model], sort: [cheapest, brandSort], defaultSort: mostExpensive)
            let selectors: [SelectorType] = [
                SelectorType.sort([cheapest, brandSort]),
                SelectorType.quant(price),
                SelectorType.quant(mileage),
                SelectorType.qual(brand),
                SelectorType.qual(model)
            ]
            let filterSelectorVC = FilterSelectorRouter.buildFilterRouterModuleFor(selectors: selectors)
            // prints all cars initially, and filtered cars every time the filter updates
            SISCar.printCars(cars, title: "All cars")
            filterCompositor.filterSort.bind { (filterSort) in
                let compositedCars = filterSort.resultForPopulation(cars)
                SISCar.printCars(compositedCars, title: "Composited cars")
            }
            
            carsFilterCompositor = filterCompositor
            return filterSelectorVC
        }
    
    }
    
}
