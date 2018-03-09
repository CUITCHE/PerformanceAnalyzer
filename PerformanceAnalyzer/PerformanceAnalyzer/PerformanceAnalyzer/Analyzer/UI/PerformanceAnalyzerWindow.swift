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

    init(frame: CGRect, analyzerItems: [MonitorType]) {
        super.init(frame: frame)
        windowLevel = UIWindowLevelStatusBar + UIWindowLevel(1 << 21)
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        setupUI(with: analyzerItems)
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

    private func setupUI(with monitorTypes: [MonitorType]) {
        for item in monitorTypes {
            let view = AnalyzerItemView(frame: .zero, itemType: item)
            addSubview(view)
            analyzerItemViews.append(view)
            view.autoMatch(.width, to: .width, of: self)
            view.autoSetDimension(.height, toSize: 20)
            view.autoPinEdge(toSuperviewEdge: .leading)
        }
        var tmp = analyzerItemViews.first!
        tmp.autoPinEdge(toSuperviewEdge: .top)
        for item in analyzerItemViews.dropFirst() {
            item.autoPinEdge(.top, to: .bottom, of: tmp)
            tmp = item
        }
    }
}

extension PerformanceAnalyzerWindow {
    @objc func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
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
