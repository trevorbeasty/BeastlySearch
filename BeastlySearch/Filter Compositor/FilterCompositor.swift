//
//  FilterCompositor.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class FilterCompositor<T>: Filtering, Sorting, FilterSelection, SortSelection {
    
    private let quantBuilders: [QuantBuilder<T>]
    private let qualBuilders: [QualBuilder<T>]
    private let sortBuilders: [SortBuilder<T>]
    private let defaultSortBuilder: SortBuilder<T>
    let filterSort = Value<FilterSort<(T)>>()
    
    func didUpdate(_ builder: QuantBuilder<T>) {
        updateFilterSort()
    }
    
    func didUpdate(_ builder: QualBuilder<T>) {
        updateFilterSort()
    }
    
    func didSelectSortBuilder(_ builder: SortBuilder<T>) {
        sorter = builder.sorter
        updateFilterSort()
    }
    
    private func updateFilterSort() {
        self.filterSort.value = FilterSort(filter: filter, sort: sorter)
    }
    
    // MARK: - Construction
    private init(quant: [QuantBuilder<T>], qual: [QualBuilder<T>], sort: [SortBuilder<T>], defaultSort: SortBuilder<T>) {
        self.quantBuilders = quant
        self.qualBuilders = qual
        self.sortBuilders = sort
        self.defaultSortBuilder = defaultSort
        sorter = defaultSortBuilder.sorter
    }
    
    static func compositorFor(quant: [QuantBuilder<T>], qual: [QualBuilder<T>], sort: [SortBuilder<T>], defaultSort: SortBuilder<T>) -> FilterCompositor<T> {
        let compositor = FilterCompositor<T>(quant: quant, qual: qual, sort: sort, defaultSort: defaultSort)
        quant.forEach({ $0.delegate = compositor })
        qual.forEach({ $0.delegate = compositor })
        sort.forEach({ $0.compositor = compositor })
        return compositor
    }
    
    // MARK: - FilterSelection
    var quantSelectors: [QuantSelectable] {
        return quantBuilders as [QuantSelectable]
    }
    var qualSelectors: [QualSelectable] {
        return qualBuilders as [QualSelectable]
    }
    var generalSearchText: String? {
        didSet { updateFilterSort() }
    }
    
    func setGeneralSearchText(_ text: String?) {
        generalSearchText = text
    }
    
    // MARK: - SortSelection
    var sortSelectors: [SortSelectable] { return sortBuilders as [SortSelectable] }
    
    // MARK: - Filter Output
    var filter: (T) -> Bool {
        return { (instance) -> Bool in
            return self.builderFilter(instance) && self.generalSearchTextFilter(instance)
        }
    }
    
    private var builderFilter: (T) -> Bool {
        return { instance -> Bool in
            if self.quantBuilders.count == 0 && self.qualBuilders.count == 0 { return true }
            var match = true
            self.quantBuilders.forEach({ (quant) in
                if quant.filter(instance) == false { match = false }
            })
            self.qualBuilders.forEach({ (qual) in
                if qual.filter(instance) == false { match = false }
            })
            return match
        }
    }
    
    private var generalSearchTextFilter: (T) -> Bool {
        return { (instance) -> Bool in
            guard let searchText = self.generalSearchText, searchText != "" else {
                return true
            }
            var match = false
            self.qualBuilders.forEach({ (builder) in
                guard builder.includeInGeneralSearch == true else { return }
                if builder.textSearchPredicate(instance[keyPath: builder.keyPath], searchText) == true { match = true }
            })
            return match
        }
    }
    
    // MARK: - Sorting
    private(set) var sorter: ((T), (T)) -> Bool
    
}




















