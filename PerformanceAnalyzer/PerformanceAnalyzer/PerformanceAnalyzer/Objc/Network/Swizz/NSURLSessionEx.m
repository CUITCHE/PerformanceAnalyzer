//
//  NSURLSession.m
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/4/11.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import "NSURLSessionEx.h"
#import "NSURLSessionDelegateProxy.h"

@implementation NSURLSession (NSURLSessionEx)

+ (NSURLSession *)sessionWithConfiguration$Ex:(NSURLSessionConfiguration *)configuration delegate:(id<NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue
{
    delegate = (id<NSURLSessionDelegate>)[NSURLSessionDelegateProxy proxyWithHandler:delegate];
    return [self sessionWithConfiguration$Ex:configuration delegate:delegate delegateQueue:queue];
}

// - (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler 最终调这个方法
- (NSURLSessionDataTask *)dataTaskWithRequest$Ex:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSLog(@"%@", @(__FUNCTION__));
    return [self dataTaskWithRequest$Ex:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completionHandler(data, response, error);
    }];
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest$Ex:(NSURLRequest *)request completionHandler:(void (^)(NSURL * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSLog(@"%@", @(__FUNCTION__));
    return [self downloadTaskWithRequest$Ex:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completionHandler(location, response, error);
    }];
}

@end
