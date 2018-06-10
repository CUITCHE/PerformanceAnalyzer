//
//  ViewController.swift
//  PerformanceAnalyzer
//
//  Created by hejunqiu on 2018/6/9.
//  Copyright © 2018 hejunqiu. All rights reserved.
//

import UIKit
import libPerformanceAnalyzer

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        var request = URLRequest(url: URL(string: "http://www.github.com")!)
        request.httpMethod = "GET"
//        request.httpBody = "hello".data(using: .utf8)!
        URLSession.shared.dataTask(with: request) { (data, request, error) in
            print("received: \(data?.count ?? 0)")
        }.resume()
    }
}

