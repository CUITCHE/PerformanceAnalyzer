//
//  OverviewViewController.swift
//  PerformanceAnalyzer
//
//  Created by hejunqiu on 2018/3/18.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {
    private var analyzerItemViews: [AnalyzerItemView] = []

    init(analyzerItems: [MonitorType]) {
        super.init(nibName: nil, bundle: nil)
        setupUI(with: analyzerItems)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    private func setupUI(with monitorTypes: [MonitorType]) {
        for item in monitorTypes {
            let view = AnalyzerItemView(frame: .zero, itemType: item)
            analyzerItemViews.append(view)
            view.autoSetDimension(.height, toSize: 20)
        }
    }

    private func setupLayout() {
        analyzerItemViews.forEach {
            view.addSubview($0)
            $0.autoMatch(.width, to: .width, of: view)
            $0.autoPinEdge(toSuperviewEdge: .leading)
        }
        var tmp = analyzerItemViews.first!
        tmp.autoPinEdge(toSuperviewEdge: .top)
        for item in analyzerItemViews.dropFirst() {
            item.autoPinEdge(.top, to: .bottom, of: tmp)
            tmp = item
        }
    }
}
