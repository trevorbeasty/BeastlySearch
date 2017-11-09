//
//  FilterCompositor.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class FilterCompositor<T>: Filtering, SortOutput, FilterSelection, SortSelection, CompositorBinding {
    
    private let quantBuilders: [QuantBuilder<T>]
    private let qualBuilders: [QualBuilder<T>]
    private let sortBuilders: [SortBuilder<T>]
    
    func didUpdate(_ builder: QuantBuilder<T>) {
        executeBindings()
    }
    
    func didUpdate(_ builder: QualBuilder<T>) {
        executeBindings()
    }
    
    func didSelectSortBuilder(_ builder: SortBuilder<T>) {
        sorter = builder.sorter
        executeBindings()
    }
    
    private func executeBindings() {
        let filterSort = FilterSort(filter: filter, sort: sorter)
        activeBindings.forEach { (binding) in
            binding(filterSort)
        }
    }
    
    // MARK: - Construction
    private init(quant: [QuantBuilder<T>], qual: [QualBuilder<T>], sort: [SortBuilder<T>]) {
        self.quantBuilders = quant
        self.qualBuilders = qual
        self.sortBuilders = sort
    }
    
    static func compositorFor(quant: [QuantBuilder<T>], qual: [QualBuilder<T>], sort: [SortBuilder<T>]) -> FilterCompositor<T> {
        let compositor = FilterCompositor<T>(quant: quant, qual: qual, sort: sort)
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
        didSet { executeBindings() }
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
        // capture self weakly?
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
    
    // MARK: - Sort Output
    var sorter: (((T), (T)) -> Bool)?
    
    // MARK: - CompositorBinding
    private(set) var activeBindings: [(FilterSort<(T)>) -> Void] = []
    
    func bind(_ binding: @escaping ((FilterSort<(T)>) -> Void)) {
        activeBindings.append(binding)
    }
    
    func removeBinding(atIndex index: Int) throws -> (FilterSort<(T)>) -> Void {
        return activeBindings.remove(at: index)
    }
    
    func removeAllBindings() {
        activeBindings.removeAll()
    }
    
}




















