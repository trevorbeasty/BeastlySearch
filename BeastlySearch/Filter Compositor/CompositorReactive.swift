//
//  CompositorReactive.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/15/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

protocol FilterSortReactive {
    associatedtype T
    var filterSort: Value<FilterSort<T>> { get }
}

protocol PopulationReactive {
    associatedtype T
    var compositedPopulation: Value<[T]> { get }
}
