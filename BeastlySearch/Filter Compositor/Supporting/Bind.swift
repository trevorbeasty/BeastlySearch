//
//  Bind.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import Foundation

protocol Bindable {
    associatedtype T
    var value: T { get }
    var bindings: [(T) -> Void] { get }
    func bind(_ binding: @escaping (T) -> Void)
    func removeBinding(atIndex index: Int) -> ((T) -> Void)
    func removeAllBindings()
}

class Value<T>: Bindable {
    var value: T {
        didSet { executeBindings() }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    // MARK: - Bindable
    private(set) var bindings: [(T) -> Void] = []
    
    func bind(_ binding: @escaping (T) -> Void) {
        bindings.append(binding)
        // execute binding immediately
        binding(value)
    }
    
    private func executeBindings() {
        bindings.forEach { (binding) in
            binding(value)
        }
    }
    
    func removeBinding(atIndex index: Int) -> ((T) -> Void) {
        return bindings.remove(at: index)
    }
    
    func removeAllBindings() {
        bindings.removeAll()
    }
}
