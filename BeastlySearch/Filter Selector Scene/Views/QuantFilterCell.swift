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
    fileprivate var increment: Int = 1000
    fileprivate var lastValue: Int?
    
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
        
        let width: CGFloat = 80
        let constraints: [NSLayoutConstraint] = [
            lowerValueLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            lowerValueLabel.rightAnchor.constraint(equalTo: slider.leftAnchor, constant: -16),
            lowerValueLabel.widthAnchor.constraint(equalToConstant: width),
            slider.rightAnchor.constraint(equalTo: upperValueLabel.leftAnchor, constant: -16),
            upperValueLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            upperValueLabel.widthAnchor.constraint(equalToConstant: width)
        ]
        constraints.forEach({ $0.isActive = true })
    }
    
    private func styleViews() {
        selectionStyle = .none
    }
    
    private func setUpSlider() {
        slider.addTarget(self, action: #selector(sliderValueDidChange(slider:)), for: .valueChanged)
    }
    
    @objc private func sliderValueDidChange(slider: UISlider) {
        guard let index = index else { return }
        let currentValue = Int(slider.value)
        // throttle
        if let lastValue = lastValue {
            let lowerBound = lastValue / increment * increment
            let upperBound = lowerBound + increment
            let searchValue: Int?
            if currentValue <= lowerBound {
                searchValue = lowerBound > 0 ? lowerBound - increment : 0
            }
            else if currentValue >= upperBound {
                searchValue = upperBound - increment
            }
            else {
                searchValue = nil
            }
            switch searchValue {
            case .some(let value):
//                print("\n\n\ndelegate called for value: \(value)\n\n\n")
                updateLabelText(lower: Int(slider.minimumValue), upper: value)
                delegate?.didSelectMax(value, forIndex: index)
            default:
                break
            }
        }
        else {
            updateLabelText(lower: Int(slider.minimumValue), upper: Int(slider.maximumValue))
        }
        lastValue = currentValue
    }
    
    private func updateLabelText(lower: Int, upper: Int) {
        lowerValueLabel.text = String(lower)
        upperValueLabel.text = String(upper)
    }
    
    private func roundedValue(_ value: Int) -> Int {
        // always rounds down
        return (value / increment) * increment
    }
    
    func configure(quantInfo: QuantSectionInfo, index: Int, delegate: QuantFilterCellOutput?) {
        slider.maximumValue = Float(quantInfo.max)
        slider.setValue(Float(quantInfo.selectedMax ?? quantInfo.max), animated: false)
        self.index = index
        self.delegate = delegate
        sliderValueDidChange(slider: slider)
    }
    
}

























