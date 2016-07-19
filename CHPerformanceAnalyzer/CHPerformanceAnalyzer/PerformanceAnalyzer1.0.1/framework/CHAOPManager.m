//
//  CHAOPManager.m
//  MobileTools
//
//  Created by hejunqiu on 16/2/9.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import "CHAOPManager.h"
#import <objc/runtime.h>

@implementation CHAOPManager

+ (void)aopInstanceMethodWithOriClass:(Class)oriClass oriSEL:(SEL)oriSelector aopClass:(Class)aopClass aopSEL:(SEL)aopSelector
{
    Method oriMethod = class_getInstanceMethod(oriClass, oriSelector);
    // class_addMethod will fail if original method already exists
    Method aopMethod = class_getInstanceMethod(aopClass, aopSelector);

    BOOL didAddMethod = class_addMethod(oriClass, oriSelector, method_getImplementation(aopMethod), method_getTypeEncoding(aopMethod));
    if (didAddMethod) { // the method doesn’t exist and we just added one
        class_replaceMethod(oriClass, aopSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    }
    else {
        class_addMethod(oriClass, aopSelector, method_getImplementation(aopMethod), method_getTypeEncoding(aopMethod));
        method_exchangeImplementations(oriMethod, aopMethod);
    }
}

+ (void)aopClassMethodWithOriClass:(Class)oriClass oriSEL:(SEL)oriSelector aopClass:(Class)aopClass aopSEL:(SEL)aopSelector
{
    Method oriMethod = class_getClassMethod(oriClass, oriSelector);
    assert(oriMethod);
    // class_addMethod will fail if original method already exists
    Method aopMethod = class_getClassMethod(aopClass, aopSelector);
    assert(aopMethod);

    BOOL didAddMethod = class_addMethod(oriClass, oriSelector, method_getImplementation(aopMethod), method_getTypeEncoding(aopMethod));
    if (!didAddMethod) { // the method doesn’t exist and we just added one
        class_replaceMethod(oriClass, aopSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    }
    else {
        method_exchangeImplementations(oriMethod, aopMethod);
    }
}

@end
