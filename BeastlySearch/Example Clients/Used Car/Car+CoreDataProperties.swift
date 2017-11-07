//
//  Car+CoreDataProperties.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/7/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    @NSManaged public var year: String
    @NSManaged public var make: String
    @NSManaged public var model: String
    @NSManaged public var mileage: Int32
    @NSManaged public var price: Int32
    @NSManaged public var id: Int32

}
