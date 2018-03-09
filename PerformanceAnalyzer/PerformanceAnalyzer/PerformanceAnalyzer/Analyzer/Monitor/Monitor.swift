//
//  Mointor.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation

enum MonitorDataType: CustomStringConvertible {
    case text(String)
    case int(Int)
    case double(Double)
    case pageLoading(String, Double, Double)

    var description: String {
        switch self {
        case .text(let val):
            return val
        case .int(let val):
            return "\(val)"
        case .double(let val):
            return "\(val)"
        case .pageLoading(_, let start, let end):
            return "\(end - start)"
        }
    }
}

enum MonitorType: String {
    case fps, memory, pageLoading, cpu, module
}

protocol MonitorDataSourceDelegate {
    func monitor(_ monitor: Monitor, occurs data: MonitorDataType)
}

protocol Monitor {
    var delegate: MonitorDataSourceDelegate? { get set }
    func start()
    func stop()
    var isMonitoring: Bool { get }
    var type: MonitorType { get }
}
