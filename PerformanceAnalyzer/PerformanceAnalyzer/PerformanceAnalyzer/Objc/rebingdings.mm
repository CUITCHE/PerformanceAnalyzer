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
#import "interceptor.h"

static ssize_t(*original_sendmsg)(int, const struct msghdr *, int);
static ssize_t(*original_recvmsg)(int, struct msghdr *, int);
static ssize_t(*original_recv)(int, void *, size_t, int);

static ssize_t my_sendmsg(int socket, const struct msghdr * msg, int flags) {
    NSMutableData *data = [NSMutableData data];
    NSLog(@"send socket: %@", @(socket));
    for (int i=0; i<msg->msg_iovlen; ++i) {
        [data appendData:[NSData dataWithBytesNoCopy:msg->msg_iov->iov_base length:msg->msg_iov->iov_len freeWhenDone:NO]];
    }
    NSLog(@"sendmsg: %@<=>%@", data, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return original_sendmsg(socket, msg, flags);
}

static ssize_t my_recvmsg(int socket, struct msghdr *msg, int flags) {
    NSMutableData *data = [NSMutableData data];
    NSLog(@"recvmsg socket: %@", @(socket));
    for (int i=0; i<msg->msg_iovlen; ++i) {
        [data appendData:[NSData dataWithBytesNoCopy:msg->msg_iov->iov_base length:msg->msg_iov->iov_len freeWhenDone:NO]];
    }
    NSLog(@"recvmsg: %@<=>%@", data, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return original_recvmsg(socket, msg, flags);
}

static ssize_t my_recv(int socket, void *buf, size_t length, int flags) {
    NSData *data = [NSData dataWithBytesNoCopy:buf length:length freeWhenDone:NO];
    NSLog(@"recv: %@<=>%@", data, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return original_recv(socket, buf, length, flags);
}

__attribute__((constructor)) void rebinding_main()
{
#define __COUNT 3
    int ret = rebind_symbols((struct rebinding[__COUNT]){
        {"sendmsg", (void *)my_sendmsg, (void **)&original_sendmsg},
        {"recvmsg", (void *)my_recvmsg, (void **)&original_recvmsg},
        {"recv", (void *)my_recv, (void **)&original_recv},
    }, __COUNT);
    printf("%d\n", ret);
#undef __COUNT
}

//static ssize_t(*original_send)(int socket, const void *buf, size_t len, int flags);
//
//static ssize_t my_send(int socket, const void *buf, size_t len, int flags) {
//    NSData *data = [[NSData alloc] initWithBytesNoCopy:(void *)buf length:len freeWhenDone:NO];
//    //    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"send: \n%@", data);
//    return original_send(socket, buf, len, flags);
//}
//
//__attribute__((constructor)) void rebinding2_main()
//{
//#define __COUNT 1
//    int ret = rebind_symbols((struct rebinding[__COUNT]){
//        {"send", (void *)my_send, (void **)&original_send}
//    }, __COUNT);
//    printf("%d\n", ret);
//}

