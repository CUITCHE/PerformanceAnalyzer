//
//  NSURLSession.h
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/4/11.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (NSURLSessionEx)

+ (NSURLSession *)sessionWithConfiguration$Ex:(NSURLSessionConfiguration *)configuration delegate:(id<NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue;

- (NSURLSessionDataTask *)dataTaskWithRequest$Ex:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler;

- (NSURLSessionDownloadTask *)downloadTaskWithRequest$Ex:(NSURLRequest *)request completionHandler:(void (^)(NSURL * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler;
@end
