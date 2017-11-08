//
//  FilterCompositor.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

class FilterCompositor<T>: FilterOutput, FilterSelection, FilterBinding {
    
    private let quantBuilders: [QuantBuilder<T>]
    private let qualBuilders: [QualBuilder<T>]
    private(set) var activeBindings: [((T) -> Bool) -> Void] = []
    
    func didUpdate(_ builder: QuantBuilder<T>) {
        executeBindings()
    }
    
    func didUpdate(_ builder: QualBuilder<T>) {
        executeBindings()
    }
    
    private func executeBindings() {
        activeBindings.forEach { (binding) in
            binding(filter)
        }
    }
    
    // MARK: - Construction
    private init(quant: [QuantBuilder<T>], qual: [QualBuilder<T>]) {
        self.quantBuilders = quant
        self.qualBuilders = qual
    }
    
    static func compositorFor(quant: [QuantBuilder<T>], qual: [QualBuilder<T>]) -> FilterCompositor<T> {
        let compositor = FilterCompositor<T>(quant: quant, qual: qual)
        quant.forEach({ $0.delegate = compositor })
        qual.forEach({ $0.delegate = compositor })
        return compositor
    }
    
    // MARK: - FilterSelector
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
    
    // MARK: - FilterOutput
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
    
    var filter: (T) -> Bool {
        return { (instance) -> Bool in
            return self.builderFilter(instance) && self.generalSearchTextFilter(instance)
        }
    }
    
    // MARK: - FilterBinding
    func bind(_ binding: @escaping (((T)) -> Bool) -> Void) {
        activeBindings.append(binding)
    }
    
    func removeBinding(atIndex index: Int) throws -> ((T) -> Bool) -> Void {
        guard index < activeBindings.count else { throw FilterBindingError.noBindingAtIndex(index) }
        return activeBindings.remove(at: index)
    }
    
    func removeAllBindings() {
        activeBindings.removeAll()
    }
    
}




















