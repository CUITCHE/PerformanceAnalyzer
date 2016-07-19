//
//  CHAOPManager.h
//  MobileTools
//
//  Created by hejunqiu on 16/2/9.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHAOPManager : NSObject

+ (void)aopInstanceMethodWithOriClass:(Class)oriClass oriSEL:(SEL)oriSelector aopClass:(Class)aopClass aopSEL:(SEL)aopSelector;
+ (void)aopClassMethodWithOriClass:(Class)oriClass oriSEL:(SEL)oriSelector aopClass:(Class)aopClass aopSEL:(SEL)aopSelector;

@end
