//
//  QuantFilterCell.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import UIKit

protocol QuantFilterCellOutput: class {
    func didSelectMin(_ value: Int, forIndex index: Int)
    func didSelectMax(_ value: Int, forIndex index: Int)
}

class QuantFilterCell: UITableViewCell {
    
    fileprivate let lowerValueLabel = UILabel()
    fileprivate let upperValueLabel = UILabel()
    fileprivate let slider = UISlider()
    
    fileprivate var index: Int?
    fileprivate var delegate: QuantFilterCellOutput?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpConstraints()
        styleViews()
        setUpSlider()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setUpConstraints() {
        let views = [lowerValueLabel, upperValueLabel, slider]
        views.forEach { (view) in
            contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        }
        
        let labels = [lowerValueLabel, upperValueLabel]
        labels.forEach { (label) in
            label.widthAnchor.constraint(equalToConstant: 80)
        }
        
        lowerValueLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        lowerValueLabel.rightAnchor.constraint(equalTo: slider.leftAnchor).isActive = true
        
        slider.rightAnchor.constraint(equalTo: upperValueLabel.leftAnchor).isActive = true
        
        upperValueLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
    
    private func styleViews() {
        selectionStyle = .none
    }
    
    private func setUpSlider() {
        slider.addTarget(self, action: #selector(sliderValueDidChange(slider:)), for: .valueChanged)
    }
    
    @objc private func sliderValueDidChange(slider: UISlider) {
        updateLabelText()
        guard let index = index else { return }
        let max = Int(slider.value)
        delegate?.didSelectMax(max, forIndex: index)
    }
    
    private func updateLabelText() {
        lowerValueLabel.text = String(slider.minimumValue)
        upperValueLabel.text = String(slider.value)
    }
    
    func configure(quantInfo: QuantSectionInfo, index: Int, delegate: QuantFilterCellOutput?) {
        slider.minimumValue = Float(quantInfo.min)
        slider.maximumValue = Float(quantInfo.max)
        slider.setValue(Float(quantInfo.selectedMax ?? quantInfo.max), animated: false)
        self.index = index
        self.delegate = delegate
        updateLabelText()
    }
    
}

























