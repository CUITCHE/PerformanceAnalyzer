//
//  UIViewControllerExtension.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit

@objc public protocol UIViewControllerAnalyzerCustom: NSObjectProtocol {
    @objc optional func hasEndFlag() -> Bool
    @objc optional func moduleName() -> String
}

extension UIViewController {
    public func _pageLoadingEnd() {
        if let flagSelf = self as? UIViewControllerAnalyzerCustom {
            if flagSelf.hasEndFlag?() == true {
                PageLoadingMonitor.shared.endFlag(with: NSStringFromClass(self.classForCoder))
            }
        }
    }
}
