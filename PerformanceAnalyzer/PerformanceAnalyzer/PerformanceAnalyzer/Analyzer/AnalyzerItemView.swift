//
//  AnalyzerItemView.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit
import PureLayout

public enum AnalyzerItemType: String {
    public struct Name: RawRepresentable {
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        public static let module      = Name(rawValue: "module")
        public static let cpu         = Name(rawValue: "cpu")
        public static let memory      = Name(rawValue: "memory")
        public static let pageLoading = Name(rawValue: "pageLoading")
        public static let fps         = Name(rawValue: "fps")
    }
    case module, cpu, memory, pageLoading, fps
}

class AnalyzerItemView: UIView {
    let label = UILabel(frame: .zero)
    let itemType: AnalyzerItemType
    var value: String = "" {
        didSet {
            switch itemType {
            case .module:
                label.text = "\(itemType.rawValue): \(value)"
            case .cpu:
                label.text = "\(itemType.rawValue): \(value)%"
            case .memory:
                label.text = "\(itemType.rawValue): \(value)MB"
            case .pageLoading:
                label.text = "\(itemType.rawValue): \(value)s"
            case .fps:
                label.text = "\(itemType.rawValue): \(value)Hz"
            }
        }
    }

    init(frame: CGRect, itemType: AnalyzerItemType) {
        self.itemType = itemType
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        label.text = itemType.rawValue
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.lineBreakMode = .byWordWrapping
        addSubview(label)
        label.autoPinEdgesToSuperviewEdges()
    }
}
