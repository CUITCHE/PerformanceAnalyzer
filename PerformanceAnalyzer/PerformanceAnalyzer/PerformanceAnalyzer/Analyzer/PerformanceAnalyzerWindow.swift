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
    var analyzerItems: Set<AnalyzerItemType> = [] {
        didSet {
            analyzerItemViews.forEach {  $0.removeFromSuperview() }
            analyzerItemViews.removeAll(keepingCapacity: true)

            for item in analyzerItems {
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

    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))

    override init(frame: CGRect) {
        super.init(frame: frame)
        windowLevel = UIWindowLevelStatusBar + UIWindowLevel(1 << 21)
        addGestureRecognizer(panGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(forView type: AnalyzerItemType, with value: String) {
        if let view = findView(with: type) {
            view.value = value
        }
    }

    private func findView(with type: AnalyzerItemType) -> AnalyzerItemView? {
        for item in analyzerItemViews where item.itemType == type {
            return item
        }
        return nil
    }
}

extension PerformanceAnalyzerWindow {
    @objc func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let location = gesture.location(in: self)
            frame = frame.offsetBy(dx: location.x, dy: location.y)
            gesture.setTranslation(.zero, in: self)
        }
    }
}
