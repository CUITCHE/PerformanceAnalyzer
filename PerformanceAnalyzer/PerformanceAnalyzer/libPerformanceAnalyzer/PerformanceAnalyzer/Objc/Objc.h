//
//  Objc.h
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/19.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#ifndef Objc_h
#define Objc_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN void instanceMethodExchange(Class clazz, SEL sel, SEL esel);
FOUNDATION_EXTERN double usageOfCurrentAPPCPU(void);
FOUNDATION_EXTERN NSInteger GetCurrentMallocAllocSize(void);

FOUNDATION_EXTERN NSString *const PAURLProtocolNetworkTaskKey;
FOUNDATION_EXTERN NSString *const PAURLProtocolStardDateKey;
FOUNDATION_EXTERN NSString *const PAURLProtocolEndDateKey;
FOUNDATION_EXTERN NSString *const PAURLProtocolErrorKey;
FOUNDATION_EXTERN void(^networkInterceptorComplete)(NSDictionary<NSString *, id> *completeArguments);
FOUNDATION_EXTERN void(^networkInterceptorRequestHeader)(NSData *allHeaderData, NSString *headerString);
FOUNDATION_EXTERN void(^networkInterceptorWillStart)(NSURLRequest *request);
NS_ASSUME_NONNULL_END
#endif /* Objc_h */
