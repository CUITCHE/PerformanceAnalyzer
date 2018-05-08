//
//  NSURLSessionDelegateProxy.h
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/4/11.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSessionDelegateProxy : NSProxy
{
    id handler;
}

+ (instancetype)proxyWithHandler:(id)handler;
@end
