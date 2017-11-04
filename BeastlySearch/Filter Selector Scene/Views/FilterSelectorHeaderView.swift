//
//  FilterSelectorHeaderView.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/4/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import UIKit

protocol FilterSelectorHeaderViewDelegate: class {
    func didTapSectionWithIndex(_ index: Int)
}

class FilterSelectorHeaderView: UITableViewHeaderFooterView {
    
    weak var delegate: FilterSelectorHeaderViewDelegate?
    var index: Int?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setUpTap()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setUpTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))
        contentView.addGestureRecognizer(tap)
    }
    
    @objc private func didTap(tap: UITapGestureRecognizer) {
        guard let index = index else { return }
        delegate?.didTapSectionWithIndex(index)
    }
    
    func configure(index: Int, delegate: FilterSelectorHeaderViewDelegate) {
        self.index = index
        self.delegate = delegate
    }

}
