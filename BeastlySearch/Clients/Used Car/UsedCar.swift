//
//  UsedCar.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

struct SISCar {
    let year: String
    let make: String
    let model: String
    let mileage: Int
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
        guard let year = jsonDict["year"] as? String,
            let make = jsonDict["make"] as? String,
            let model = jsonDict["model"] as? String,
            let mileage = jsonDict["mileage"] as? Int,
            let images = jsonDict["images"] as? [JSONDict] else {
                return nil
        }
        let imagePaths = images.flatMap { $0["path"] as? String }
        self.init(year: year, make: make, model: model, mileage: mileage, imagePaths: imagePaths)
    }
}

extension SISCar: CustomStringConvertible {
    public var description: String {
        return "\(year) \(make) \(model), mileage: \(mileage) miles"
    }
}

extension SISCar {
    static func printCars(_ cars: [SISCar], title: String) {
        print("\n" + title + ":\n")
        cars.forEach { (car) in
            print(car)
        }
    }
}
