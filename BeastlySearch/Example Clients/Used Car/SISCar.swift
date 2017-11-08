//
//  UsedCar.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

struct SISCar {
    let id: Int
    let year: String
    let make: String
    let model: String
    let mileage: Int
    let price: Int
    let imagePaths: [String]
}

enum SISCarError: Error {
    case bundleResourceError
}

typealias JSONDict = [String : Any]

extension SISCar {
    static func allUsedCars() -> [SISCar] {
        do {
            guard let carsURL = Bundle.main.url(forResource: "all-used-cars", withExtension: "json") else {
                throw SISCarError.bundleResourceError
            }
            let carsData = try Data(contentsOf: carsURL)
            let carsJSONObject = try JSONSerialization.jsonObject(with: carsData, options: [])
            let carsJSONDicts = carsJSONObject as! [JSONDict]
            return carsJSONDicts.flatMap({ SISCar(jsonDict: $0) })
        }
        catch {
            print(error)
            fatalError()
        }
    }
    
    init?(jsonDict: JSONDict) {
        guard
            let id = jsonDict["id"] as? Int,
            let year = jsonDict["year"] as? String,
            let make = jsonDict["make"] as? String,
            let model = jsonDict["model"] as? String,
            let mileage = jsonDict["mileage"] as? Int,
            let price = jsonDict["price"] as? Int,
            let images = jsonDict["images"] as? [JSONDict] else {
                return nil
        }
        let imagePaths = images.flatMap { $0["path"] as? String }
        self.init(id: id, year: year, make: make, model: model, mileage: mileage, price: price, imagePaths: imagePaths)
    }
}

extension SISCar: CustomStringConvertible {
    public var description: String {
        return "\(id) - \(year) \(make) \(model), mileage: \(mileage) miles, price: \(price)"
    }
}

extension SISCar {
    static func printCars(_ cars: [SISCar], title: String) {
        print("\n" + title + ":\n")
        guard cars.count > 0 else {
            print("zero cars")
            return
        }
        cars.forEach { (car) in
            print(car)
        }
    }
}


















