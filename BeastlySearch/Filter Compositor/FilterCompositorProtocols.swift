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

protocol FilterBinding: class {
    associatedtype T
    var activeBindings: [((T) -> Bool) -> Void] { get }
    func bind(_ binding: @escaping ((T) -> Bool) -> Void)
    func removeBinding(atIndex index: Int) throws -> ((T) -> Bool) -> Void
    func removeAllBindings()
}

protocol FilterSelection: class {
    var quantSelectors: [QuantSelectable] { get }
    var qualSelectors: [QualSelectable] { get }
    var generalSearchText: String? { get }
    func setGeneralSearchText(_ text: String?)
}
