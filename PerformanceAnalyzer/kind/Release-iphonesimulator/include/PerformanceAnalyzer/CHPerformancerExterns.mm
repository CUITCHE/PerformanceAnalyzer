//
//  CHPerformancerExterns.mm
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/4/6.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import "CHPerformancerExterns.h"
#import "CHPerformanceAnalyzer.h"

@implementation CHPerformancerExterns

@end

void(^CHPerformanceAnalyzerAOPInitializer)() = {};

NSString *CHPerformanceAnalyzerApplicationDelegateClassName = @"AppDelegate";

CHPerformanceAnalyzerShowType CHPerformanceAnalyzerShowTypeSetting = CHPerformanceAnalyzerShowTypeAll;