//
//  ModuleMonitor.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/9.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation

class ModuleMonitor: Monitor {
    static let shared = ModuleMonitor()

    var delegate: MonitorDataSourceDelegate?

    func start() {
        // Always monitoring
    }

    func stop() {
        // Always monitoring
    }

    func switchPage(_ name: String) {
        delegate?.monitor(self, occurs: .text(name))
    }

    var isMonitoring: Bool { return true }

    var type: MonitorType { return .module }


}

