//
//  FilterSelectorRouter.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class FilterSelectorRouter {
    
    static func buildFilterRouterModuleFor(selectors: [FilterSelectorType]) -> FilterSelectorViewController {
        let sections = FilterSelectorRouter.sectionsForSelectors(selectors)
        
        let view = FilterSelectorViewController(sections: sections)
        let presenter = FilterSelectorPresenter(filterSelectors: selectors)
        view.presenter = presenter
        
        return view
    }
    
    static func sectionsForSelectors(_ selectors: [FilterSelectorType]) -> [SectionType] {
        return selectors.map { (selector) -> SectionType in
            switch selector {
            case .quant(let quant):
                let quantInfo = QuantSectionInfo(quant: quant)
                return SectionType.quant(quantInfo)
                
            case .qual(let qualSelectable):
                let values = Array(qualSelectable.values)
                let qualInfo = QualSectionInfo(name: qualSelectable.name, values: values)
                return SectionType.qual(qualInfo)
            }
        }
    }
    
}
