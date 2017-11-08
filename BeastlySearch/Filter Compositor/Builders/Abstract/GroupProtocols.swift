//
//  GroupProtocols.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

// associatedtype ?
protocol QuantInfo {
    var min: Int { get }
    var max: Int { get }
}

protocol QualInfo {
    var values: Set<String> { get }
}
