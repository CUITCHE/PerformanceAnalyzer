//
//  CHGlobalDefines.m
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import "CHGlobalDefines.h"
#include <objc/runtime.h>
#include <malloc/malloc.h>

@implementation CHGlobalDefines

@end

union __save_count_ivar__ {
    uint32_t count;
    Ivar *p;
};

NSUInteger accurateInstanceMemoryReserved(id instance)
{
#define POINTER_SIZE sizeof(void*)
    NSUInteger reserved = 0;
    do {
        if (!instance) {
            reserved = POINTER_SIZE;
            break;
        }
        if ([instance isMemberOfClass:[NSObject class]]) {
            break;
        }
        void *c_instance = (__bridge void*)instance;
        reserved = malloc_size(c_instance);
        union __save_count_ivar__ u;
        u.count = 0;
        Class cls = [instance class];
        Ivar *ivars = class_copyIvarList(cls, &u.count);
        if (!ivars) { // NULL, but also calculate pointer size
            reserved += POINTER_SIZE;
            break;
        }
        Ivar *ivarsEnd = ivars + u.count;
        u.p = ivars - 1;
        while (++u.p < ivarsEnd) {
            const char *type = ivar_getTypeEncoding(*u.p);
            if (type[0] == '@') {
                if (type[1] == '\"' && type[2] != '<') { // This is a delegate, avoid to recycle.
                    NSString *key = [NSString stringWithUTF8String:ivar_getName(*u.p)];
                    id value = [instance valueForKey:key];
                    reserved += accurateInstanceMemoryReserved(value);
                }
            } else if (type[0] == '^') { // get malloc size of C/C++ style pointer
                const void *ptr = c_instance + ivar_getOffset(*u.p);
                reserved += malloc_size(ptr);
            }
        }
        free(ivars);
        // check whether instance is array or dictionary or not.
        if ([instance respondsToSelector:@selector(objectEnumerator)]) {
            NSEnumerator *enumerator = [instance performSelector:@selector(objectEnumerator)];
            id obj = enumerator.nextObject;
            while (obj) {
                reserved += accurateInstanceMemoryReserved(obj);
                obj = enumerator.nextObject;
            }
        }
    } while (0);
    return reserved;
}