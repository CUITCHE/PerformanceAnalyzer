//
//  CGPointExtension.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/9.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}
