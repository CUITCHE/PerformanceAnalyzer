//
//  PerformanceAnalyzer.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit

public class PerformanceAnalyzer {
    public static let `defualt` = PerformanceAnalyzer(monitorTypes: [.fps, .memory, .pageLoading, .cpu, .module])
    private let monitors: [MonitorType: Monitor] = [.fps: FPSMonitor.shared, .memory: MemoryMonitor.shared,
                                                    .pageLoading: PageLoadingMonitor.shared, .cpu: CPUMonitor.shared,
                                                    .module: ModuleMonitor.shared]
    let monitorTypes: [MonitorType]
    var window: PerformanceAnalyzerWindow!
    var monitorData: [MonitorDataModel] = []

    init(monitorTypes: [MonitorType]) {
        self.monitorTypes = monitorTypes
        monitorData.reserveCapacity(1024 * 16)
        UIViewController.exchangeMethods()
    }

    public func startAnalysis() {
        window = PerformanceAnalyzerWindow(frame: .init(x: 10, y: 64, width: UIScreen.main.bounds.width - 10 * 2, height: 200))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.window.backgroundColor = .white
            self.window.rootViewController = OverviewViewController(analyzerItems: self.monitorTypes)
            self.window.makeKeyAndVisible()
        }

        for type in monitorTypes {
            if var monitor = monitors[type] {
                monitor.delegate = self
                monitor.start()
            }
        }
    }

    public func stopAnalysis() {
        for type in monitorTypes {
            if let monitor = monitors[type] {
                monitor.stop()
            }
        }
        window.isHidden = true
        window = nil
    }
}

extension PerformanceAnalyzer: MonitorDataSourceDelegate {
    func monitor(_ monitor: Monitor, occurs data: MonitorDataType, at time: MonitorTimeInterval) {
        switch data {
        case .text(let name):
            monitorData.append(.module(name: name, timeline: time))
        case .int(let memory):
            monitorData.append(.memory(bytes: memory, timeline: time))
        case .double(let val):
            monitorData.append(monitor is FPSMonitor ? .fps(hertz: val, timeline: time): .cpu(percent: val, timeline: time))
        case .pageLoading(_, let start, let end):
            monitorData.append(.pageLoading(name: ModuleMonitor.shared.currentModuleName, interval: end - start, timeline: time))
        }
        window.update(forView: monitor.type, with: data)
    }
}
