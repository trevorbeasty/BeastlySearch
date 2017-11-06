//
//  FilterSelectorViewController.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import UIKit

protocol OpenClose {
    var isOpen: Bool { get set }
}

extension OpenClose {
    mutating func toggleIsOpen() {
        isOpen = !isOpen
    }
}

enum SectionType {
    case quant(QuantSectionInfo)
    case qual(QualSectionInfo)
}

struct QuantSectionInfo: OpenClose {
    let name: String
    let min: Int
    let max: Int
    let converter: IntConverter
    let increment: Int
    var isOpen: Bool
    var selectedMin: Int?
    var selectedMax: Int?
    
    init(name: String, min: Int, max: Int, converter: @escaping IntConverter, increment: Int, isOpen: Bool = true, selectedMin: Int? = nil, selectedMax: Int? = nil) {
        self.name = name
        self.min = min
        self.max = max
        self.converter = converter
        self.increment = increment
        self.isOpen = isOpen
        self.selectedMin = selectedMin
        self.selectedMax = selectedMax
    }
}

extension QuantSectionInfo {
    init(quant: QuantSelectable & QuantExpressive, isOpen: Bool = true, selectedMin: Int? = nil, selectedMax: Int? = nil) {
        self.name = quant.name
        self.min = quant.min
        self.max = quant.max
        self.converter = quant.converter
        self.increment = quant.increment
        self.isOpen = isOpen
        self.selectedMin = selectedMin
        self.selectedMax = selectedMax
    }
}

struct QualSectionInfo: OpenClose {
    let name: String
    let values: [String]
    var isOpen: Bool
    
    init(name: String, values: [String], isOpen: Bool = false) {
        self.name = name
        self.values = values
        self.isOpen = isOpen
    }
}

protocol FilterSelectorViewControllerOutput: class {
    func didSelectValue(_ value: String, forIndex index: Int)
    func didDeselectValue(_ value: String, forIndex index: Int)
}

fileprivate struct Constants {
    static let quantCellID = "QuantFilterCell"
    static let qualCellID = "QualFilterCell"
    static let quantHeaderID = "QuantHeaderView"
    static let qualHeaderID = "QualHeaderView"
}

class FilterSelectorViewController: UIViewController {

    var presenter: (FilterSelectorViewControllerOutput & QuantFilterCellOutput)?
    
    fileprivate let tableView = UITableView()
    
    var sections: [SectionType]
    fileprivate var selectedPaths = Set<IndexPath>()
    
    init(sections: [SectionType]) {
        self.sections = sections
        super.init(nibName: nil, bundle: nil)
        setUpConstraints()
        styleViews()
        setUpTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraints()
        styleViews()
        setUpTableView()
    }
    
    private func setUpConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let constraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        constraints.forEach({ $0.isActive = true })
    }
    
    private func styleViews() {
        
    }
    
    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(QuantFilterCell.self, forCellReuseIdentifier: Constants.quantCellID)
        tableView.register(QualFilterCell.self, forCellReuseIdentifier: Constants.qualCellID)
        tableView.register(QuantHeaderView.self, forHeaderFooterViewReuseIdentifier: Constants.quantHeaderID)
        tableView.register(QualHeaderView.self, forHeaderFooterViewReuseIdentifier: Constants.qualHeaderID)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }

}

extension FilterSelectorViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .quant(let quantInfo):
            return quantInfo.isOpen ? 1 : 0
        case .qual(let qualInfo):
            return qualInfo.isOpen ? qualInfo.values.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .quant(let quantInfo):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.quantCellID, for: indexPath) as! QuantFilterCell
            cell.configure(quantInfo: quantInfo, index: indexPath.section, delegate: presenter)
            return cell
            
        case .qual(let qualInfo):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.qualCellID, for: indexPath) as! QualFilterCell
            let value = qualInfo.values[indexPath.row]
            let selected = selectedPaths.contains(indexPath)
            cell.configure(value, selected: selected)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch sections[section] {
        case .quant(let quantInfo):
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.quantHeaderID) as! QuantHeaderView
            header.configure(index: section, delegate: self)
            header.configure(quantInfo: quantInfo)
            return header
        
        case .qual(let qualInfo):
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.qualHeaderID) as! QualHeaderView
            header.configure(index: section, delegate: self)
            header.configure(qualInfo: qualInfo)
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
}

extension FilterSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .qual(let qualInfo):
            let value = qualInfo.values[indexPath.row]
            let index = indexPath.section
            let cell = tableView.cellForRow(at: indexPath) as? QualFilterCell
            if selectedPaths.contains(indexPath) {
                selectedPaths.remove(indexPath)
                presenter?.didDeselectValue(value, forIndex: index)
                cell?.configure(false)
            }
            else {
                selectedPaths.insert(indexPath)
                presenter?.didSelectValue(value, forIndex: index)
                cell?.configure(true)
            }
        default:
            break
        }
    }
}

extension FilterSelectorViewController: FilterSelectorHeaderViewDelegate {
    func didTapSectionWithIndex(_ index: Int) {
        print("did tap: \(index)")
        switch sections[index] {
        case .qual(var qualInfo):
            qualInfo.toggleIsOpen()
            sections[index] = SectionType.qual(qualInfo)
            tableView.reloadData()
        default:
            break
        }
    }
}

















