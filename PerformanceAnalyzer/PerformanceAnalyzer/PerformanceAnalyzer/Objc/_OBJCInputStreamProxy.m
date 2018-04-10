//
//  _OBJCInputStreamProxy.m
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/4/10.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import "_OBJCInputStreamProxy.h"

@implementation _OBJCInputStreamProxy

+ (instancetype)inputStreamWithStream:(id)stream {
    _OBJCInputStreamProxy *proxy = [_OBJCInputStreamProxy alloc];
    proxy->stream = stream;
    return proxy;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self->stream];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [self->stream methodSignatureForSelector:sel];
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {
    NSInteger readSize = [stream read:buffer maxLength:len];
    NSLog(@"Download: %zi bytes.", readSize);
    return readSize;
}
@end
