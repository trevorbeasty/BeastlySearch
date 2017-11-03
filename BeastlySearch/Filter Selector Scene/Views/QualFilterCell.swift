//
//  QualFilterCell.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import UIKit

class QualFilterCell: UITableViewCell {
    
    fileprivate let label = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
            label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 32)
        ]
        constraints.forEach({ $0.isActive = true })
    }
    
    private func styleViews() {
        selectionStyle = .none
    }
    
    func configure(_ value: String, selected: Bool) {
        label.text = value
        configure(selected)
    }
    
    func configure(_ selected: Bool) {
        if selected {
            backgroundColor = .blue
            label.textColor = .white
        }
        else {
            backgroundColor = .white
            label.textColor = .darkGray
        }
    }

}
