//
//  CHGlobalDefines.h
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHMetaMacro.h"

/* Fake */
@interface CHGlobalDefines : NSObject

@end

typedef NS_OPTIONS(NSUInteger, CHPerformanceAnalyzerShowType) {
    CHPerformanceAnalyzerShowTypeCPU = 1,
    CHPerformanceAnalyzerShowTypeMemory = 1 << 1,
    CHPerformanceAnalyzerShowTypePageLoading = 1 << 2,
    CHPerformanceAnalyzerShowTypeFPS = 1 << 3,
    CHPerformanceAnalyzerShowTypeAll = CHPerformanceAnalyzerShowTypeCPU | CHPerformanceAnalyzerShowTypeMemory | CHPerformanceAnalyzerShowTypePageLoading | CHPerformanceAnalyzerShowTypeFPS
};

typedef NS_ENUM(uint8_t, CHInternalIndex) {
    CHInternalIndexModule       = 0x0,
    CHInternalIndexCPU          = 0x1,
    CHInternalIndexMemory       = 0x2,
    CHInternalIndexPageLoading  = 0x3,
    CHInternalIndexFPS          = 0x4,
    CHInternalIndexCount
};

#define option_check(var, opt) (((var) & (opt))==opt)