//
//  OverviewViewController.swift
//  PerformanceAnalyzer
//
//  Created by hejunqiu on 2018/3/18.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit
import PureLayout

class OverviewViewController: UIViewControllerAnalyzer {
    private enum DataSourceIndex: Int {
        case fps, memory, pageLoading, cpu, module
        static func map(_ type: MonitorType) -> DataSourceIndex {
            switch type {
            case .fps: return .fps
            case .memory: return .memory
            case .pageLoading: return .pageLoading
            case .cpu: return .cpu
            case .module: return .module
            case .network: // The
                assertionFailure("The .network don't need UI.")
                exit(-1)
            }
        }
    }
    private let analyzerItems: [MonitorType]
    private let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    private var dataSource: [MonitorDataType] = [.double(0), MonitorDataType.int(0), .pageLoading("", 0, 0), .double(0), .text("")]

    init(analyzerItems: [MonitorType]) {
        self.analyzerItems = analyzerItems
        super.init(nibName: nil, bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .hex(0xffe5e5e5)
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView()
        tableView.register(AnalyzerItemView.self, forCellReuseIdentifier: "cell")
        tableView.bounces = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.autoPinEdge(toSuperviewEdge: .top, withInset: 24)
        tableView.autoPinEdge(toSuperviewEdge: .leading)
        tableView.autoPinEdge(toSuperviewEdge: .trailing)
        tableView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
    }
}

extension OverviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return analyzerItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 24
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AnalyzerItemView
        cell.itemType = analyzerItems[indexPath.row]
        cell.tag = analyzerItems[indexPath.row].hashValue
        if indexPath.row < dataSource.count {
            cell.value = dataSource[DataSourceIndex.map(cell.itemType).rawValue]
        }
        return cell
    }
}

extension OverviewViewController: PerformanceAnalyzerViewControllerDelegate {
    func setValue(_ value: MonitorDataType, for type: MonitorType) {
        dataSource[DataSourceIndex.map(type).rawValue] = value
        tableView.reloadRows(at: [IndexPath.init(row: DataSourceIndex.map(type).rawValue, section: 0)], with: .none)
    }
}
