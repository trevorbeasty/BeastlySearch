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
    
    fileprivate var info: QuantSectionInfo?
    fileprivate var index: Int?
    fileprivate var delegate: QuantFilterCellOutput?
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
        }
        
        let labels = [lowerValueLabel, upperValueLabel]
        labels.forEach { (label) in
            label.widthAnchor.constraint(equalToConstant: 80)
        }
        
        let height: CGFloat = 44
        let sliderInset: CGFloat = 32
        let constraints: [NSLayoutConstraint] = [
            slider.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            slider.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor, constant: sliderInset),
            slider.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor, constant: -1 * sliderInset),
            lowerValueLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 8),
            lowerValueLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            lowerValueLabel.rightAnchor.constraint(equalTo: upperValueLabel.leftAnchor, constant: -8),
            lowerValueLabel.widthAnchor.constraint(equalTo: upperValueLabel.widthAnchor, multiplier: 1.0),
            lowerValueLabel.heightAnchor.constraint(equalToConstant: height),
            lowerValueLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            upperValueLabel.topAnchor.constraint(equalTo: lowerValueLabel.topAnchor),
            upperValueLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            upperValueLabel.heightAnchor.constraint(equalToConstant: height)
        ]
        constraints.forEach({ $0.isActive = true })
        
        let border: CGFloat = 0
        contentView.layoutMargins = UIEdgeInsets(top: border, left: border, bottom: border, right: border)
    }
    
    private func styleViews() {
        selectionStyle = .none
        
        let labels = [lowerValueLabel, upperValueLabel]
        labels.forEach({ label in
            label.textAlignment = .center
        })
    }
    
    private func setUpSlider() {
        slider.addTarget(self, action: #selector(sliderValueDidChange(slider:)), for: .valueChanged)
    }
    
    @objc private func sliderValueDidChange(slider: UISlider) {
        guard let index = index, let increment = info?.increment else { return }
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
//            print("\n\n\(slider.maximumValue)\n\n")
            let initialMax = (Int(slider.maximumValue) / increment) * increment + increment
            updateLabelText(lower: Int(slider.minimumValue), upper: initialMax)
        }
        lastValue = currentValue
    }
    
    private func updateLabelText(lower: Int, upper: Int) {
        lowerValueLabel.text = info?.converter(lower)
        upperValueLabel.text = info?.converter(upper)
    }
    
    func configure(quantInfo: QuantSectionInfo, index: Int, delegate: QuantFilterCellOutput?) {
        self.info = quantInfo
        slider.maximumValue = Float(quantInfo.max)
        slider.setValue(Float(quantInfo.selectedMax ?? quantInfo.max), animated: false)
        self.index = index
        self.delegate = delegate
        sliderValueDidChange(slider: slider)
    }
    
}

























