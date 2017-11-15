//
//  FilterSelectorVCSections.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

protocol OpenClose {
    var isOpen: Bool { get set }
}

extension OpenClose {
    mutating func toggleIsOpen() {
        isOpen = !isOpen
    }
}

enum SectionType {
    case quant(QuantSectionInfo)
    case qual(QualSectionInfo)
    case sort(SortSectionInfo)
}

struct QuantSectionInfo: OpenClose {
    let name: String
    let min: Int
    let max: Int
    let converter: IntConverter
    let increment: Int
    var isOpen: Bool
    var selectedMin: Int?
    var selectedMax: Int?
    
    init(name: String, min: Int, max: Int, converter: @escaping IntConverter, increment: Int, isOpen: Bool = true, selectedMin: Int? = nil, selectedMax: Int? = nil) {
        self.name = name
        self.min = min
        self.max = max
        self.converter = converter
        self.increment = increment
        self.isOpen = isOpen
        self.selectedMin = selectedMin
        self.selectedMax = selectedMax
    }
}

extension QuantSectionInfo {
    init(quant: QuantSelectable & QuantExpressive, isOpen: Bool = true, selectedMin: Int? = nil, selectedMax: Int? = nil) {
        self.name = quant.name
        self.min = quant.min.value
        self.max = quant.max.value
        self.converter = quant.converter
        self.increment = quant.increment
        self.isOpen = isOpen
        self.selectedMin = selectedMin
        self.selectedMax = selectedMax
    }
}

struct QualSectionInfo: OpenClose {
    let name: String
    let values: [String]
    var isOpen: Bool
    
    init(name: String, values: [String], isOpen: Bool = false) {
        self.name = name
        self.values = values
        self.isOpen = isOpen
    }
}

struct SortSectionInfo {
    let values: [String]
    
    init(sorts: [SortSelectable]) {
        self.values = sorts.map({ sort -> String in
            return sort.name
        })
    }
}























