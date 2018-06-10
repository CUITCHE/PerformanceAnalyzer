//
//  ModuleMonitor.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/9.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation
import UIKit.UIViewController

class ModuleMonitor: Monitor {
    var delegate: MonitorDataSourceDelegate?

    func start() {
        // Always monitoring
    }

    func stop() {
        // Always monitoring
    }

    func `switch`(page name: String) {
        delegate?.monitor(self, occurs: .text(name), at: currentTime())
    }

    var isMonitoring: Bool { return true }

    var type: MonitorType { return .module }

    /// Get the module name of current view controller.
    ///
    /// The order of geting-name:
    /// - If view controller conforms protocol UIViewControllerAnalyzerCustom and implement the `moduleName`.
    /// - The vc.title if it's valid.
    /// - The vc.navigationItem.title if it's vaild.
    /// - Return nil.
    var currentModuleName: String? {
        guard let curvc = currentViewController else { return nil }
        if let vc = curvc as? UIViewControllerAnalyzerCustom, let title = vc.moduleName?() {
            return title
        }
        if let title = curvc.title {
            return title
        }
        if let title = curvc.navigationItem.title {
            return title
        }
        return "undefine"
    }
    var currentViewController: UIViewController?
}

extension ModuleMonitor: MonitorShared {
    static let shared = ModuleMonitor()
}
