//
//  SortHeaderView.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import UIKit

protocol SortHeaderViewDelegate: class {
    func didSelectIndex(_ index: Int)
}

class SortHeaderView: UITableViewHeaderFooterView {

    private var segmentedControl = UISegmentedControl()
    
    var delegate: SortHeaderViewDelegate?
    
    func configure(info: SortSectionInfo, delegate: SortHeaderViewDelegate) {
        segmentedControl.removeFromSuperview()
        segmentedControl = segmentedControlFor(info: info)
        self.delegate = delegate
    }
    
    private func segmentedControlFor(info: SortSectionInfo) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: info.values)
        setUpConstraintsFor(segmentedControl: segmentedControl)
        setUpSegmentedControl(segmentedControl)
        return segmentedControl
    }
    
    private func setUpConstraintsFor(segmentedControl: UISegmentedControl) {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(segmentedControl)
        
        let constraints: [NSLayoutConstraint] = [
            segmentedControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        constraints.forEach({ $0.isActive = true })
    }
    
    private func setUpSegmentedControl(_ segmentedControl: UISegmentedControl) {
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueDidChange(sender:)), for: .valueChanged)
    }
    
    @objc private func segmentedControlValueDidChange(sender: UISegmentedControl) {
        delegate?.didSelectIndex(sender.selectedSegmentIndex)
    }

}
















