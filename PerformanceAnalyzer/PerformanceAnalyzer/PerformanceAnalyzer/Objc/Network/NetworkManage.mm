//
//  NetwokManage.m
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/4/11.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import "NetworkManage.h"
#include <unordered_map>
#import <QuartzCore/CABase.h>

using namespace::std;

struct NetworkRecordData {
    NetworkRecordData(int) { }

    CFTimeInterval requestStartTime = 0;
    CFTimeInterval requestEndTime = 0;
    NSString *erroString = nil; // connection:didFailWithError:
    CFTimeInterval responseStartTime = 0;
    CFTimeInterval responseEndTime = 0;

    NSInteger sentBytes = 0;
    NSInteger receivedBytes = 0;
};

struct NetworkManagePrivate {
    NetworkManagePrivate() { }
    unordered_map<uintptr_t, NetworkRecordData> map;
    id delegate;
};

#define Q_D(class) class##Private *d = (class##Private *)(this->data)

NetworkManage& NetworkManage::standard()
{
    static NetworkManage *ins = new NetworkManage();
    return *ins;
}

NetworkManage::NetworkManage(): data(new NetworkManagePrivate()) { }

NetworkManage::~NetworkManage()
{
    delete data;
    data = nullptr;
}

void NetworkManage::setDelegate(id delegate)
{
    Q_D(NetworkManage);
    d->delegate = delegate;
}

void NetworkManage::append(NSURLConnection *c)
{
    Q_D(NetworkManage);
    d->map.emplace(reinterpret_cast<uintptr_t>(c), 1);
}

void NetworkManage::startedRequest(NSURLConnection *c)
{
    Q_D(NetworkManage);
    auto iter = d->map.find(reinterpret_cast<uintptr_t>(c));
    if (iter != d->map.end()) {
        iter->second.requestStartTime = CACurrentMediaTime();
    }
}

void NetworkManage::sentBytes(NSURLConnection *c, NSInteger bytes)
{
    Q_D(NetworkManage);
    auto iter = d->map.find(reinterpret_cast<uintptr_t>(c));
    if (iter != d->map.end()) {
        iter->second.sentBytes += bytes;
    }
}

void NetworkManage::endedRequest(NSURLConnection *c)
{
    Q_D(NetworkManage);
    auto iter = d->map.find(reinterpret_cast<uintptr_t>(c));
    if (iter != d->map.end()) {
        iter->second.responseEndTime = CACurrentMediaTime();
    }
}

void NetworkManage::receivedResponse(NSURLConnection *c)
{
    Q_D(NetworkManage);
    auto iter = d->map.find(reinterpret_cast<uintptr_t>(c));
    if (iter != d->map.end()) {
        iter->second.responseStartTime = CACurrentMediaTime();
    }
}

void NetworkManage::receivedBytes(NSURLConnection *c, NSInteger bytes)
{
    Q_D(NetworkManage);
    auto iter = d->map.find(reinterpret_cast<uintptr_t>(c));
    if (iter != d->map.end()) {
        iter->second.receivedBytes += bytes;
    }
}

void NetworkManage::finallyFinishing(NSURLConnection *c)
{
    Q_D(NetworkManage);
    auto iter = d->map.find(reinterpret_cast<uintptr_t>(c));
    if (iter != d->map.end()) {
        iter->second.responseEndTime = CACurrentMediaTime();
        auto val = iter->second;
        NSLog(@"%@", @(val.receivedBytes));
    }
}

void NetworkManage::endWithError(NSURLConnection *c, NSError *error)
{
    Q_D(NetworkManage);
    auto iter = d->map.find(reinterpret_cast<uintptr_t>(c));
    if (iter != d->map.end()) {
        iter->second.erroString = error.localizedDescription;
        iter->second.responseEndTime = CACurrentMediaTime();
    }
}
