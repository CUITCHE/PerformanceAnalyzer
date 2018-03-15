//
//  PageLoadingMonitor.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation
import QuartzCore.CABase

class PageLoadingMonitor: Monitor {
    var delegate: MonitorDataSourceDelegate?
    private var startTime: TimeInterval = 0
    private var flag: Bool = false
    var isMonitoring: Bool { return flag }
    var type: MonitorType { return .pageLoading }

    func start() {
        flag = true
    }

    func stop() {
        flag = false
    }

    func startFlag() {
        if flag {
            startTime = CACurrentMediaTime()
        }
    }

    func endFlag(with vc: String) {
        if flag {
            delegate?.monitor(self, occurs: .pageLoading(vc, startTime, CACurrentMediaTime()), at: currentTime())
        }
    }
}

extension PageLoadingMonitor: MonitorShared {
    static let shared = PageLoadingMonitor()
}
