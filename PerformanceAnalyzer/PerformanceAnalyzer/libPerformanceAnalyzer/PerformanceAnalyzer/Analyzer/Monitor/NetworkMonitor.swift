//
//  NetworkMonitor.swift
//  libPerformanceAnalyzer
//
//  Created by hejunqiu on 2018/6/9.
//  Copyright © 2018 hejunqiu. All rights reserved.
//

import UIKit

class NetworkMonitor: Monitor {
    var delegate: MonitorDataSourceDelegate?
    var _isMonitoring: Bool = true
    func start() {
        _isMonitoring = true
    }

    func stop() {
        _isMonitoring = false
    }

    var isMonitoring: Bool { return _isMonitoring }

    var type: MonitorType { return .network }


    private var semaphoreData = DispatchSemaphore(value: 1)
    class HTTPModel {
        struct RecordModel {
            let header: Int
            let body: Int
        }
        let method: String
        let url: String
        let startDate: TimeInterval = Date().timeIntervalSince1970
        let request: URLRequest
        var requestHeaderBytesCount: Int = -1
        var responseData: RecordModel?
        var endDate: TimeInterval?
        init(method: String, url: String, request: URLRequest) {
            self.method = method
            self.url = url
            self.request = request
        }

        var key: String { return method + url }
    }
    typealias RecordHostKey = String
    var record = [HTTPModel]()

    init() {
        networkInterceptorWillStart = {[weak self] request in
            guard let `self` = self else { return }
            self.semaphoreData.wait()
            self.record.append(HTTPModel(method: request.httpMethod ?? "GET", url: request.url?.absoluteString ?? "<CR>/<LF>", request: request))
            self.semaphoreData.signal()
        }
        networkInterceptorRequestHeader = { [weak self] (data, allHeaders) in
            guard let `self` = self else { return }
            let lines = allHeaders.split(separator: "\r\n")
            assert(lines.count >= 2, "Error: Parsing request")

            var sub = lines[0].split(separator: " ")
            assert(sub.count >= 3, "Error: Parsing request line: \(lines[0])")
            let method = sub[0]
            let scheme = sub[1]

            sub = lines[1].split(separator: " ")
            assert(sub.count == 2, "Error: Parsing request Host line: \(lines[1])")
            let host = sub[1]

            let key = method + host + scheme

            self.semaphoreData.wait()
            for val in self.record.reversed() where val.key == key && val.requestHeaderBytesCount == -1 {
                val.requestHeaderBytesCount = data.count
                break
            }
            self.semaphoreData.signal()
        }
        networkInterceptorComplete = { arguments in
            print("start date: ", arguments[PAURLProtocolStardDateKey]!, "end date: ", arguments[PAURLProtocolEndDateKey]!)
        }
    }
}

extension NetworkMonitor: MonitorShared {
    static let shared = NetworkMonitor()
}
