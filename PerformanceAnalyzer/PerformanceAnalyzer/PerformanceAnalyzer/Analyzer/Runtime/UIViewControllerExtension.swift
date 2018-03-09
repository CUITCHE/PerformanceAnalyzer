//
//  UIViewControllerExtension.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit

@objc public protocol UIViewControllerAnalyzerCustomEndFlag: NSObjectProtocol {
    @objc var hasEndFlag: Bool { get }
}

extension UIViewController {
    public func _pageLoadingEnd() {
        if let flagSelf = self as? UIViewControllerAnalyzerCustomEndFlag {
            if flagSelf.hasEndFlag {
                PageLoadingMonitor.shared.endFlag(with: NSStringFromClass(self.classForCoder))
            }
        }
    }
}
