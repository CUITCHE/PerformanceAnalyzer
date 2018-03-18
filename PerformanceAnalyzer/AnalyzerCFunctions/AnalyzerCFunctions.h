//
//  AnalyzerCFunctions.h
//  AnalyzerCFunctions
//
//  Created by hejunqiu on 2018/3/18.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for AnalyzerCFunctions.
FOUNDATION_EXPORT double AnalyzerCFunctionsVersionNumber;

//! Project version string for AnalyzerCFunctions.
FOUNDATION_EXPORT const unsigned char AnalyzerCFunctionsVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AnalyzerCFunctions/PublicHeader.h>


FOUNDATION_EXTERN void instanceMethodExchange(Class clazz, SEL sel, SEL esel);
FOUNDATION_EXTERN double usageOfCurrentAPPCPU();
FOUNDATION_EXTERN NSInteger GetCurrentMallocAllocSize();
