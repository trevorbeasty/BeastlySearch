//
//  BuilderErrors.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

enum QualSelectorError: Error, CustomStringConvertible {
    case invalidValue(String)
    
    var description: String {
        switch self {
        case .invalidValue(let value):
            return "\(value) is not a member of QualGroup.values"
        }
    }
}
