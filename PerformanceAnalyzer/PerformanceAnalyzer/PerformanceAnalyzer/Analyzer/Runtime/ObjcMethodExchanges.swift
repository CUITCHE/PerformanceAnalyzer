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
        PageLoadingMonitor.shared.startFlag()
        loadView$Ex()
    }

    @objc private func viewWillAppear$Ex(_ animated: Bool) {
        ModuleMonitor.shared.switch(page: NSStringFromClass(self.classForCoder))
        ModuleMonitor.shared.currentViewController = self
        viewWillAppear$Ex(animated)
    }

    @objc private func viewDidAppear$Ex(_ animated: Bool) {
        viewDidAppear$Ex(animated)
        if let flagSelf = self as? UIViewControllerAnalyzerCustom {
            if flagSelf.hasEndFlag?() ?? false == false {
                PageLoadingMonitor.shared.endFlag(with: NSStringFromClass(self.classForCoder))
            }
        } else {
            PageLoadingMonitor.shared.endFlag(with: NSStringFromClass(self.classForCoder))
        }
    }

    @objc private func viewWillDisappear$Ex(_ animated: Bool) {
        ModuleMonitor.shared.currentViewController = nil
        viewWillDisappear$Ex(animated)
    }

    static func exchangeMethods() {
        let cls = UIViewController.self
        instanceMethodExchange(cls, #selector(loadView), #selector(loadView$Ex))
        instanceMethodExchange(cls, #selector(viewWillAppear(_:)), #selector(viewWillAppear$Ex(_:)))
        instanceMethodExchange(cls, #selector(viewDidAppear(_:)), #selector(viewDidAppear$Ex(_:)))
        instanceMethodExchange(cls, #selector(viewWillDisappear(_:)), #selector(viewWillDisappear$Ex(_:)))
    }
}
