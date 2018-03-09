//
//  ObjcMethodExchanges.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit
import AnalyzerCFunction

extension UIViewController {
    @objc private func loadView$Ex() {
        ModuleMonitor.shared.switchPage(NSStringFromClass(self.classForCoder))
        PageLoadingMonitor.shared.startFlag()
        loadView$Ex()
    }

    @objc private func viewDidAppear$Ex(_ animated: Bool) {
        viewDidAppear$Ex(animated)
        guard PageLoadingMonitor.shared.isNeedTime else { return }

        if let flagSelf = self as? UIViewControllerAnalyzerCustomEndFlag {
            if !flagSelf.hasEndFlag {
                PageLoadingMonitor.shared.endFlag(with: NSStringFromClass(self.classForCoder))
            }
        } else {
            PageLoadingMonitor.shared.endFlag(with: NSStringFromClass(self.classForCoder))
        }
    }

    static func exchangeMethods() {
        func UIViewControllerEx() {
            let cls = UIViewController.self
            instanceMethodExchange(cls, #selector(loadView), #selector(loadView$Ex))
            instanceMethodExchange(cls, #selector(viewDidAppear(_:)), #selector(viewDidAppear$Ex(_:)))
        }
        UIViewControllerEx()
    }
}
