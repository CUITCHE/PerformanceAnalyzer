//
//  PerformanceAnalyzerWindow.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit

class PerformanceAnalyzerWindow: UIWindow {
    private var analyzerItemViews: [AnalyzerItemView] = []
    var startPoint: CGPoint = .zero

    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 7
        layer.shadowOffset = CGSize(width: 0, height: 4)
        windowLevel = UIWindowLevelStatusBar + UIWindowLevel(1 << 21)
        addGestureRecognizer(panGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(forView type: MonitorType, with value: MonitorDataType) {
        if let view = findView(with: type) {
            view.value = value
        }
    }

    private func findView(with type: MonitorType) -> AnalyzerItemView? {
        for item in analyzerItemViews where item.itemType == type {
            return item
        }
        return nil
    }
}

extension PerformanceAnalyzerWindow {
    @objc private func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            startPoint = gesture.location(in: self)
        } else if gesture.state == .changed {
            let location = gesture.location(in: self) - startPoint
            var frame = self.frame.offsetBy(dx: location.x, dy: location.y)
            if frame.minX < 10 {
                frame.origin.x = 10
            } else if frame.maxX > UIScreen.main.bounds.maxX - 10 {
                frame.origin.x = UIScreen.main.bounds.maxX - 10 - frame.width
            }

            if frame.minY < 64 {
                frame.origin.y = 64
            } else if frame.maxY > UIScreen.main.bounds.maxY - 10 {
                frame.origin.y = UIScreen.main.bounds.maxY - 10 - frame.height
            }
            self.frame = frame
        }
    }
}
