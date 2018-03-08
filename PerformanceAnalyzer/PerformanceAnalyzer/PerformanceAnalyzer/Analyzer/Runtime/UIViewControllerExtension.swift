//
//  UIViewControllerExtension.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit

@objc public protocol UIViewControllerAnalyzerCustomEndFlag: NSObjectProtocol {
    @objc optional var hasEndFlag: Bool { get }
}

extension UIViewController {
    public func _pageLoadingEnd() {
        
    }
}
