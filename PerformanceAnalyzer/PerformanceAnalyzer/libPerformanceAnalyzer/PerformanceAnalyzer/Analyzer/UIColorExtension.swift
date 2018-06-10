//
//  UIColorExtension.swift
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/19.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

import UIKit.UIColor


extension UIColor {
    static func hex(_ value: Int) -> UIColor {
        let alpha: CGFloat = CGFloat((value & 0xff000000) >> 24) / 255.0
        let red: CGFloat = CGFloat((value & 0xff0000) >> 16) / 255.0
        let green: CGFloat = CGFloat((value & 0x00ff00) >> 8) / 255.0
        let blue: CGFloat = CGFloat((value & 0x0000ff)) / 255.0

        if #available(iOS 10.0, *) {
            return UIColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}
