//
//  runtime.m
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/4/11.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURLSessionEx.h"
#import "NSURLSessionTaskEx.h"

FOUNDATION_EXTERN void instanceMethodExchange(Class clazz, SEL sel, SEL esel);
FOUNDATION_EXTERN void classMethodExchange(Class clazz, SEL sel, SEL esel);

__attribute__((constructor)) void exchanges_main()
{
//    Class clazz = [NSURLConnection class];
//    instanceMethodExchange(clazz, @selector(initWithRequest:delegate:), @selector(initWithRequest$Ex:delegate:));
//    instanceMethodExchange(clazz, @selector(initWithRequest:delegate:startImmediately:), @selector(initWithRequest$Ex:delegate:startImmediately:));
//    instanceMethodExchange(clazz, @selector(start), @selector(start$Ex));
//    instanceMethodExchange(clazz, @selector(cancel), @selector(cancel$Ex));

    Class clazz = [NSURLSession class];
    classMethodExchange(clazz, @selector(sessionWithConfiguration:delegate:delegateQueue:), @selector(sessionWithConfiguration$Ex:delegate:delegateQueue:));
    instanceMethodExchange(clazz, @selector(dataTaskWithRequest:completionHandler:), @selector(dataTaskWithRequest$Ex:completionHandler:));
    instanceMethodExchange(clazz, @selector(downloadTaskWithRequest:completionHandler:), @selector(downloadTaskWithRequest$Ex:completionHandler:));

    instanceMethodExchange([NSURLSessionTask class], @selector(resume), @selector(resume$Ex));
}
