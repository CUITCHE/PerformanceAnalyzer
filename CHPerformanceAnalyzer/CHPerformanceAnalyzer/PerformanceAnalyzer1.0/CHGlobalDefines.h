//
//  CHGlobalDefines.h
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHMetaMacro.h"

#define PA_API_AVAILABLE(availbale_started)
#define PA_CLASS_AVAILABLE(availbale_started)
#define PA_API_DEPRECATED(deprecated_started)

#define option_check(var, opt) (((var) & (opt))==opt)

#define PA_VERSION 1.1

FOUNDATION_EXTERN NSString *const PA_VERSION_STRING;

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

typedef NS_OPTIONS(uint8_t, CHPAMonitorType) PA_API_AVAILABLE(1.1) {
    CHPAMonitorTypeNone = 0,
    CHPAMonitorTypeSQLExecute = 1,
    CHPAMonitorTypeUIRefreshInMainThread = 1 << 1
};