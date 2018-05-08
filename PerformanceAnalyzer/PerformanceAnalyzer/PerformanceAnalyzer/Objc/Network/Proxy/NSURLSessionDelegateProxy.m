//
//  NSURLSessionDelegateProxy.m
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/4/11.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import "NSURLSessionDelegateProxy.h"

@implementation NSURLSessionDelegateProxy

+ (instancetype)proxyWithHandler:(id)handler
{
    NSURLSessionDelegateProxy *proxy = [self alloc];
    proxy->handler = handler;
    return proxy;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self->handler];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [self->handler methodSignatureForSelector:sel];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if ([handler respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [handler URLSession:session task:task didCompleteWithError:error];
    }
}
@end
