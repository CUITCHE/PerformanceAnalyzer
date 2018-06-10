    //
    //  rebingdings.m
    //  Performance
    //
    //  Created by hejunqiu on 2018/3/18.
    //  Copyright © 2018年 hejunqiu. All rights reserved.
    //

#import <fishhook/fishhook.h>
#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/tcp.h>
#import <sys/socketvar.h>
#import <sys/mman.h>
#import <sys/uio.h>

void(^networkInterceptorRequestHeader)(NSData *allHeaderData, NSString *headerString) = nil;

static ssize_t(*original_sendmsg)(int, const struct msghdr *, int);
static ssize_t my_sendmsg(int socket, const struct msghdr * msg, int flags) {
    if (networkInterceptorRequestHeader) {
        NSMutableData *data = [NSMutableData data];
        for (int i=0; i<msg->msg_iovlen; ++i) {
            [data appendData:[NSData dataWithBytesNoCopy:msg->msg_iov->iov_base length:msg->msg_iov->iov_len freeWhenDone:NO]];
        }
        NSLog(@"header length: %@", @(data.length));
        NSString *requestHeader = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([requestHeader containsString:@"Host: "]) {
            networkInterceptorRequestHeader(data, requestHeader);
        }
    }
    return original_sendmsg(socket, msg, flags);
}

#import "PAURLProtocol.h"

__attribute__((constructor)) void rebinding_main()
{
#define __COUNT 1
    int ret = rebind_symbols((struct rebinding[__COUNT]){
        {"sendmsg", (void *)my_sendmsg, (void **)&original_sendmsg},
    }, __COUNT);
    printf("%d\n", ret);
    [NSURLProtocol registerClass:[PAURLProtocol self]];
#undef __COUNT
}
