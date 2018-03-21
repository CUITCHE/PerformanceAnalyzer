//
//  Objc.h
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/3/19.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#ifndef Objc_h
#define Objc_h

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN void instanceMethodExchange(Class clazz, SEL sel, SEL esel);
FOUNDATION_EXTERN double usageOfCurrentAPPCPU(void);
FOUNDATION_EXTERN NSInteger GetCurrentMallocAllocSize(void);

#endif /* Objc_h */
