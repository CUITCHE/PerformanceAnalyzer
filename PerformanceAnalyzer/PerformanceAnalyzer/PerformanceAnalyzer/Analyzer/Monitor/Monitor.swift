//
//  Mointor.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation

enum MonitorDataType {
    case text(String)
    case int(Int)
    case double(Double)
    case pageLoading(String, Double, Double)
}

protocol MonitorDataSourceDelegate {
    func monitor(_ monitor: Monitor, occurs data: MonitorDataType)
}

protocol Monitor {
    var delegate: MonitorDataSourceDelegate? { get set }
    func start()
    func stop()
}
