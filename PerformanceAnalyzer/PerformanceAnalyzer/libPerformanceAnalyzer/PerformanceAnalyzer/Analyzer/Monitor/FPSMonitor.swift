//
//  FPSMointer.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation
import QuartzCore.CADisplayLink

class FPSMonitor: Monitor {

    var delegate: MonitorDataSourceDelegate?

    private var lastTime: CFTimeInterval = 0
    private var count: Int = 0
    private var updater: CADisplayLink! = nil
    var isMonitoring: Bool { return updater != nil }
    var type: MonitorType { return .fps }

    func start() {
        updater = CADisplayLink(target: self, selector: #selector(onUpdater(_:)))
        updater.add(to: .main, forMode: .commonModes)
    }

    func stop() {
        updater.invalidate()
        updater = nil
    }

    @objc private func onUpdater(_ displayLink: CADisplayLink) {
        guard lastTime != 0 else {
            lastTime = displayLink.timestamp
            return
        }
        count += 1
        let delta = displayLink.timestamp - lastTime
        guard delta >= 1 else { return }

        let fps = CFTimeInterval(count) / delta
        delegate?.monitor(self, occurs: .double(fps), at: currentTime())
        count = 0
        lastTime = displayLink.timestamp
    }
}

extension FPSMonitor: MonitorShared {
    static let shared = FPSMonitor()
}
