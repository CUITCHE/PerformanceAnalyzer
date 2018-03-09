//
//  PerformanceAnalyzer.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit

class PerformanceAnalyzer {
    
    private let monitors: [MonitorType: Monitor] = [.fps: FPSMonitor.shared, .memory: MemoryMonitor.shared,
                                                    .pageLoading: PageLoadingMonitor.shared, .cpu: CPUMonitor.shared,
                                                    .module: ModuleMonitor.shared]
    let monitorTypes: [MonitorType]
    var window: PerformanceAnalyzerWindow!

    init(monitorTypes: [MonitorType]) {
        self.monitorTypes = monitorTypes
        UIViewController.exchangeMethods()
    }

    func startAnalysis() {
        self.window = PerformanceAnalyzerWindow(frame: .init(x: 10, y: 64, width: 310, height: 100), analyzerItems: self.monitorTypes)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.window.makeKeyAndVisible()
        }

        for type in monitorTypes {
            if var monitor = monitors[type] {
                monitor.delegate = self
                monitor.start()
            }
        }
    }

    func stopAnalysis() {
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
    func monitor(_ monitor: Monitor, occurs data: MonitorDataType) {
        window.update(forView: monitor.type, with: data)
    }
}
