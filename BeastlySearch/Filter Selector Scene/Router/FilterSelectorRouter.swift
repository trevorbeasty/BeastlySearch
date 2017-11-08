//
//  FilterSelectorRouter.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class FilterSelectorRouter {
    
    static func buildFilterRouterModuleFor(selectors: [SelectorType]) -> FilterSelectorViewController {
        let sections = FilterSelectorRouter.viewSectionsForFilterSelectors(selectors: selectors)
        
        let view = FilterSelectorViewController(sections: sections)
        let presenter = FilterSelectorPresenter(selectors: selectors)
        view.presenter = presenter
        
        return view
    }
    
    private static func viewSectionsForFilterSelectors(selectors: [SelectorType]) -> [SectionType] {
        return selectors.map { (selector) -> SectionType in
            switch selector {
            case .quant(let quant):
                let quantInfo = QuantSectionInfo(quant: quant)
                return SectionType.quant(quantInfo)

            case .qual(let qualSelectable):
                let values = Array(qualSelectable.values)
                let qualInfo = QualSectionInfo(name: qualSelectable.name, values: values)
                return SectionType.qual(qualInfo)
                
            case .sort(let sortSelectables):
                let sortInfo = SortSectionInfo(sorts: sortSelectables)
                return SectionType.sort(sortInfo)
            }
        }
    }
    
}
