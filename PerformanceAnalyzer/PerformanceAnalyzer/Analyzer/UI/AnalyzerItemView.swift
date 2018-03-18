//
//  AnalyzerItemView.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit
import PureLayout

class AnalyzerItemView: UIView {
    let label = UILabel(frame: .zero)
    let itemType: MonitorType
    var value: MonitorDataType = .int(0) {
        didSet {
            switch itemType {
            case .module:
                label.text = "\(itemType.rawValue): \(value)"
            case .cpu:
                label.text = "\(itemType.rawValue): \(value)%"
            case .memory:
                if case let .int(val) = value {
                    let mb = Double(val) / 1024 / 1024
                    label.text = "\(itemType.rawValue): \(mb)MB"
                }
            case .pageLoading:
                label.text = "\(itemType.rawValue): \(value)s"
            case .fps:
                label.text = "\(itemType.rawValue): \(value)Hz"
            }
        }
    }

    init(frame: CGRect, itemType: MonitorType) {
        self.itemType = itemType
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        label.text = itemType.rawValue
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        addSubview(label)
        label.autoPinEdgesToSuperviewEdges()
    }
}
