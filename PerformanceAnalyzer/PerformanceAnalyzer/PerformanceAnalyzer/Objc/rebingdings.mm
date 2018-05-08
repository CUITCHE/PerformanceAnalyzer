//
//  rebingdings.m
//  Performance
//
//  Created by hejunqiu on 2018/3/18.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <fishhook/fishhook.h>
#import <Foundation/Foundation.h>
#import "_NSInputStreamProxy.h"

static CFReadStreamRef (*original_CFReadStreamCreateForHTTPRequest)(CFAllocatorRef __nullable alloc,
                                                                    CFHTTPMessageRef request);

static CFReadStreamRef MyCFReadStreamCreateForHTTPRequest(CFAllocatorRef alloc,
                                                          CFHTTPMessageRef request) {
    // 使用系统方法的函数指针完成系统的实现
    CFReadStreamRef originalCFStream = original_CFReadStreamCreateForHTTPRequest(alloc, request);
    // 将 CFReadStreamRef 转换成 NSInputStream，并保存在 XXInputStreamProxy，最后返回的时候再转回 CFReadStreamRef
    NSInputStream *stream = (__bridge NSInputStream *)originalCFStream;
    _NSInputStreamProxy *outStream = [_NSInputStreamProxy inputStreamWithStream:stream];
    CFRelease(originalCFStream);
    CFReadStreamRef result = (__bridge_retained CFReadStreamRef)outStream;
    return result;
}

__attribute__((constructor)) void rebinding_main()
{
#define __COUNT 1
    int ret = rebind_symbols((struct rebinding[__COUNT]){
        {"CFReadStreamCreateForHTTPRequest", (void *)MyCFReadStreamCreateForHTTPRequest, (void **)&original_CFReadStreamCreateForHTTPRequest}
    }, __COUNT);
    printf("%d\n", ret);
}
