//
//  FilterSelection.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

protocol FilterSelection: class {
    var quantSelectors: [QuantSelectable] { get }
    var qualSelectors: [QualSelectable] { get }
    var generalSearchText: String? { get }
    func setGeneralSearchText(_ text: String?)
}
