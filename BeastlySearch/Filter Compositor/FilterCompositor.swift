//
//  FilterCompositor.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class FilterCompositor<T>: Filtering, Sorting, FilterSelection, SortSelection, MacroSelection {
    
    private let quantBuilders: [QuantBuilder<T>]
    private let qualBuilders: [QualBuilder<T>]
    private let sortBuilders: [SortBuilder<T>]
    private let macroBuilders: [MacroBuilder<T>]
    private let defaultSortBuilder: SortBuilder<T>
    let filterSort: Value<FilterSort<(T)>>
    
    func didUpdate(_ builder: QuantBuilder<T>) {
        updateFilterSort()
    }
    
    func didUpdate(_ builder: QualBuilder<T>) {
        updateFilterSort()
    }
    
    func selectSortBuilder(_ builder: SortBuilder<T>) {
        if selectedSortBuilder == builder { return }
        selectedSortBuilder?.isSelected.value = false
        builder.isSelected.value = true
        selectedSortBuilder = builder
        updateFilterSort()
    }
    
    func deselectSortBuilder(_ builder: SortBuilder<T>) {
        // only one sort builder should ever be selected at a time
        // deselecting a sort builder selects the default sort, if one exists
        if builder == selectedSortBuilder {
            builder.isSelected.value = false
            selectedSortBuilder = nil
            updateFilterSort()
        }
    }
    
    func didSelectMacroBuilder(_ builder: MacroBuilder<T>) {
        let filterSort = FilterSort(
            filter: builder.filter,
            sorter: builder.sorter ?? defaultSortBuilder.sorter)
        self.filterSort.value = filterSort
    }
    
    private func updateFilterSort() {
        self.filterSort.value = FilterSort(filter: filter, sorter: sorter)
    }
    
    // MARK: - Construction
    private init(quant: [QuantBuilder<T>], qual: [QualBuilder<T>], sort: [SortBuilder<T>], macro: [MacroBuilder<T>], defaultSort: SortBuilder<T>, generalSearchText: String? = nil) {
        self.quantBuilders = quant
        self.qualBuilders = qual
        self.sortBuilders = sort
        self.macroBuilders = macro
        self.defaultSortBuilder = defaultSort
        self.generalSearchText = generalSearchText
        let filter = FilterCompositor.filterFor(quants: quant, quals: qual, generalSearchText: generalSearchText)
        sortBuilders.forEach({ $0.deselect() })
        let filterSort = FilterSort<T>(filter: filter, sorter: defaultSortBuilder.sorter)
        self.filterSort = Value(filterSort)
    }
    
    static func compositorFor(quant: [QuantBuilder<T>], qual: [QualBuilder<T>], sort: [SortBuilder<T>] = [], macro: [MacroBuilder<T>] = [], defaultSort: SortBuilder<T>, generalSearchText: String? = nil) -> FilterCompositor<T> {
        let compositor = FilterCompositor<T>(quant: quant, qual: qual, sort: sort, macro: macro, defaultSort: defaultSort, generalSearchText: generalSearchText)
        quant.forEach({ $0.delegate = compositor })
        qual.forEach({ $0.delegate = compositor })
        sort.forEach({ $0.compositor = compositor })
        macro.forEach({ $0.compositor = compositor })
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
    
    // MARK: - MacroSelection
    var macroSelectors: [MacroSelectable] { return macroBuilders as [MacroSelectable] }
    
    // MARK: - Filtering
    var filter: (T) -> Bool {
        return FilterCompositor.builderFilterFor(quants: quantBuilders, quals: qualBuilders)
    }
    
    private static func filterFor(quants: [QuantBuilder<T>], quals: [QualBuilder<T>], generalSearchText: String?) -> ((T) -> Bool) {
        let builderFilter = builderFilterFor(quants: quants, quals: quals)
        let searchTextFilter = generalSearchTextFilterFor(quals: quals, generalSearchText: generalSearchText)
        return { instance -> Bool in
            builderFilter(instance) && searchTextFilter(instance)
        }
    }
    
    private static func builderFilterFor(quants: [QuantBuilder<T>], quals: [QualBuilder<T>]) -> ((T) -> Bool) {
        return { instance -> Bool in
            if quants.count == 0 && quals.count == 0 { return true }
            var match = true
            quants.forEach({ (quant) in
                if quant.filter(instance) == false { match = false }
            })
            quals.forEach({ (qual) in
                if qual.filter(instance) == false { match = false }
            })
            return match
        }
    }
    
    private static func generalSearchTextFilterFor(quals: [QualBuilder<T>], generalSearchText: String?) -> ((T) -> Bool) {
        return { (instance) -> Bool in
            guard let searchText = generalSearchText, searchText != "" else {
                return true
            }
            var match = false
            quals.forEach({ (builder) in
                guard builder.includeInGeneralSearch == true else { return }
                if builder.textSearchPredicate(instance[keyPath: builder.keyPath], searchText) == true { match = true }
            })
            return match
        }
    }
    
    // MARK: - Sorting
    private var selectedSortBuilder: SortBuilder<T>?
    var sorter: ((T), (T)) -> Bool {
        return selectedSortBuilder?.sorter ?? defaultSortBuilder.sorter
    }
    
}




















