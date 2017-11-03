//
//  FilterCompositorProtocols.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

protocol FilterOutput: class {
    associatedtype T
    var filter: (T) -> Bool { get }
}

protocol FilterCompositorDelegate: class {
    associatedtype T
    func didUpdateFilter(_ filter: (T) -> Bool)
}

protocol FilterSelection: class {
    var quantSelectors: [QuantSelectable] { get }
    var qualSelectors: [QualSelectable] { get }
    var generalSearchText: String? { get }
    func setGeneralSearchText(_ text: String?)
}
