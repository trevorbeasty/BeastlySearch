//
//  GeneralTextSearchable.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

// (baseString, searchText) -> Bool
typealias TextSearchPredicate = (String, String) -> Bool

protocol GeneralTextSearchable {
    var includeInGeneralSearch: Bool { get }
    var textSearchPredicate: TextSearchPredicate { get }
}
