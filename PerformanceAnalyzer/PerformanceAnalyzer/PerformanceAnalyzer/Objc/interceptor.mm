//
//  interceptor.m
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/6/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import "interceptor.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <netdb.h>
#import <net/if.h>
#import <sys/ioctl.h>
#import <errno.h>

extern int errno;

static int sock = 0;

void intercept()
{
    sock = socket(AF_INET, SOCK_RAW, IPPROTO_TCP);
    if (sock == -1) {
        NSLog(@"%@", @(errno));
        perror(strerror(errno));
        assert(0 && "init socket failed");
        return;
    }
    char name[128];
    if (gethostname(name, sizeof(name)) == -1) {
        close(sock);
        assert(0 && "Get localhost name error.");
        return;
    }
    struct hostent *phostent = gethostbyname(name);
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr = *(struct in_addr *)phostent->h_addr_list[0]; // IP
    addr.sin_port = 80; // 随意填写
    if (SO_ERROR == bind(sock, (struct sockaddr *)&addr, sizeof(addr))) {
        close(sock);
        assert(0 && "bind error");
        return;
    }
//    u_long sioarg = 1;
//    if (SO_ERROR == ioctl(sock, SIOALL)) {
//        <#statements#>
//    }
    u_long bioarg = 0;
    if (SO_ERROR == ioctl(sock, FIONBIO, &bioarg)) {
        close(sock);
        assert(0 && "设置阻塞模式失败");
        return;
    }
    dispatch_async(dispatch_queue_create("com.hejunqiu.background", nil), ^{
        fd_set fds;
        struct timeval timeout = {3, 0};
        int maxfdp = 0;
        char buf[65535];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        for (; ; ) {
            __DARWIN_FD_ZERO(&fds);
            __DARWIN_FD_SET(sock, &fds);
            switch (select(maxfdp, &fds, &fds, NULL, &timeout)) {
                case -1:
                    assert(0 && "error!");
                    break;
                case 0: break;
                default:
                    if (__DARWIN_FD_ISSET(sock, &fds)) {
                        int len = (int)recv(sock, buf, sizeof(buf), 0);
                        if (len > 0) {
                            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                            NSData *data = [NSData dataWithBytesNoCopy:buf length:len freeWhenDone:NO];
                            NSLog(@"low layer data: %@", data);
                            dispatch_semaphore_signal(semaphore);
                        }
                    }
                    break;
            }
        }
    });
}
