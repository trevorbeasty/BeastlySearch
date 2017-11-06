//
//  FilterSelectorPresenter.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

enum FilterSelectorType {
    case quant(QuantSelectable & QuantExpressive)
    case qual(QualSelectable)
}

enum FilterSelectorPresenterError: Error {
    case expectedQuantSelectableForIndex(Int)
    case expectedQualSelectableForIndex(Int)
}

class FilterSelectorPresenter: QuantFilterCellOutput, FilterSelectorViewControllerOutput {
    
    let filterSelectors: [FilterSelectorType]
    
    init(filterSelectors: [FilterSelectorType]) {
        self.filterSelectors = filterSelectors
    }
    
    // MARK: - FilterSelectorViewControllerOutput
    func didSelectValue(_ value: String, forIndex index: Int) {
        do {
            let qualSelectable = try qualSelectableForIndex(index)
            try qualSelectable.selectValue(value)
        }
        catch {
            print(error)
        }
    }
    
    func didDeselectValue(_ value: String, forIndex index: Int) {
        do {
            let qualSelectable = try qualSelectableForIndex(index)
            try qualSelectable.deselectValue(value)
        }
        catch {
            print(error)
        }
    }
    
    private func qualSelectableForIndex(_ index: Int) throws -> QualSelectable {
        switch filterSelectors[index] {
        case .qual(let qualSelectable):
            return qualSelectable
        default:
            throw FilterSelectorPresenterError.expectedQualSelectableForIndex(index)
        }
    }
    
    // MARK: - QuantFilterCellOutput
    func didSelectMin(_ value: Int, forIndex index: Int) {
        do {
            let quantSelectable = try quantSelectableForIndex(index)
            quantSelectable.selectMin(value)
        }
        catch {
            print(error)
        }
    }
    
    func didSelectMax(_ value: Int, forIndex index: Int) {
        do {
            let quantSelectable = try quantSelectableForIndex(index)
            quantSelectable.selectMax(value)
        }
        catch {
            print(error)
        }
    }
    
    private func quantSelectableForIndex(_ index: Int) throws -> QuantSelectable {
        switch filterSelectors[index] {
        case .quant(let quantSelectable):
            return quantSelectable
        default:
            throw FilterSelectorPresenterError.expectedQuantSelectableForIndex(index)
        }
    }
    
}













