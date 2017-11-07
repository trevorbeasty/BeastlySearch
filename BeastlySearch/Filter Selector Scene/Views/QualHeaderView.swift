//
//  QualHeaderView.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/4/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import UIKit

class QualHeaderView: FilterSelectorHeaderView {
    
    fileprivate let label = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setUpConstraints()
        styleViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setUpConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        let constraints: [NSLayoutConstraint] = [
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8)
        ]
        constraints.forEach({ $0.isActive = true })
    }
    
    private func styleViews() {
        
    }
    
    func configure(qualInfo: QualSectionInfo) {
        label.text = qualInfo.name
    }

}
