//
//  AnalyzerCFunction.h
//  AnalyzerCFunction
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

//! Project version number for AnalyzerCFunction.
FOUNDATION_EXPORT double AnalyzerCFunctionVersionNumber;

//! Project version string for AnalyzerCFunction.
FOUNDATION_EXPORT const unsigned char AnalyzerCFunctionVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AnalyzerCFunction/PublicHeader.h>

FOUNDATION_EXTERN void instanceMethodExchange(Class clazz, SEL sel, SEL esel);
FOUNDATION_EXTERN double usageOfCurrentAPPCPU();
FOUNDATION_EXTERN NSInteger GetCurrentMallocAllocSize();
