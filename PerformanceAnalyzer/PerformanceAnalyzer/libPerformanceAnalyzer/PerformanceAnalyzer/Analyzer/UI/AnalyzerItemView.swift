//
//  AnalyzerItemView.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit
import PureLayout

class AnalyzerItemView: UITableViewCell {
    var itemType: MonitorType = .cpu
    var value: MonitorDataType = .int(0) {
        didSet {
            switch itemType {
            case .module:
                textLabel?.text = "\(itemType.rawValue): \(value)"
            case .cpu:
                textLabel?.text = "\(itemType.rawValue): \(value)%"
            case .memory:
                if case let .int(val) = value {
                    let mb = Double(val) / 1024 / 1024
                    textLabel?.text = "\(itemType.rawValue): \(mb)MB"
                }
            case .pageLoading:
                textLabel?.text = "\(itemType.rawValue): \(value)s"
            case .fps:
                textLabel?.text = "\(itemType.rawValue): \(value)Hz"
            case .network:
                textLabel?.text = "Wrong Operate."
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.textColor = .hex(0xff666666)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
