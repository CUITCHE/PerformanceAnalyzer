//
//  CHPerformanceDataPackager.m
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import "CHPerformanceDataPackager.h"
#import "CHGlobalDefines.h"
#import "CHPerformanceData.h"
#import <CoreGraphics/CGBase.h>

@interface CHPerformanceDataPackager ()

@property (nonatomic) NSInteger type;

@end

@implementation CHPerformanceDataPackager

+ (instancetype)packagerWithPerformanceShowType:(NSInteger)type
{
    CHPerformanceDataPackager *packager = [CHPerformanceDataPackager new];
    packager.type = type;
    return packager;
}


- (NSString *)performanceDataLocalizedToCSV
{
    NSMutableString *text = [NSMutableString stringWithCapacity:1024 * 4];
    Class slf = [self class];
    // do for cpu
    if (option_check(_type, CHPerformanceAnalyzerShowTypeCPU)) {
        [slf assignHeaderToText:text withPrefix:@"CPU"];
        [_dataSource enumerateKeysAndObjectsUsingBlock:^(NSString *key, CHPerformanceData *obj, BOOL *stop) {
            [slf assignCPUText:text withPerformanceData:obj];
        }];
        [text appendString:@"\n"];
    }

    // do for memory
    if (option_check(_type, CHPerformanceAnalyzerShowTypeMemory)) {
        [slf assignHeaderToText:text withPrefix:@"Memory"];
        [_dataSource enumerateKeysAndObjectsUsingBlock:^(NSString *key, CHPerformanceData *obj, BOOL *stop) {
            [slf assignMemoryText:text withPerformanceData:obj];
        }];
        [text appendString:@"\n"];
    }

    // do for fps
    if (option_check(_type, CHPerformanceAnalyzerShowTypeFPS)) {
        [slf assignHeaderToText:text withPrefix:@"FPS"];
        [_dataSource enumerateKeysAndObjectsUsingBlock:^(NSString *key, CHPerformanceData *obj, BOOL *stop) {
            [slf assignFPSText:text withPerformanceData:obj];
        }];
        [text appendString:@"\n"];
    }

    // do for loading time
    if (option_check(_type, CHPerformanceAnalyzerShowTypePageLoading)) {
        [slf assignHeaderToText:text withPrefix:@"Loading Time"];
        [_dataSource enumerateKeysAndObjectsUsingBlock:^(NSString *key, CHPerformanceData *obj, BOOL *stop) {
            [slf assignLoadingTimeText:text withPerformanceData:obj];
        }];
        [text appendString:@"\n"];
    }
    return text;
}

+ (void)assignHeaderToText:(NSMutableString *)text withPrefix:(NSString *)prefix
{
    [text appendFormat:@"Module Name,%@(Average)\n", prefix];//,%@(Max),%@(Min)
}

+ (void)assignCPUText:(NSMutableString *)text withPerformanceData:(CHPerformanceData *)performance
{
    [text appendString:performance.moduleName];
    [text appendFormat:@",%@", [self calculateStatistics:performance.cpu]];
    for (NSNumber *v in performance.cpu) {
        [text appendFormat:@",%@", v];
    }
    [text appendString:@"\n"];
}

+ (void)assignMemoryText:(NSMutableString *)text withPerformanceData:(CHPerformanceData *)performance
{
    [text appendString:performance.moduleName];
    [text appendFormat:@",%@", [self calculateStatistics:performance.memory]];
    for (NSNumber *v in performance.memory) {
        [text appendFormat:@",%@", v];
    }
    [text appendString:@"\n"];
}

+ (void)assignFPSText:(NSMutableString *)text withPerformanceData:(CHPerformanceData *)performance
{
    [text appendString:performance.moduleName];
    [text appendFormat:@",%@", [self calculateStatistics:performance.fps]];
    for (NSNumber *v in performance.fps) {
        [text appendFormat:@",%@", v];
    }
    [text appendString:@"\n"];
}

+ (void)assignLoadingTimeText:(NSMutableString *)text withPerformanceData:(CHPerformanceData *)performance
{
    [text appendString:performance.moduleName];
    [text appendFormat:@",%@", [self calculateStatistics:performance.loadingTime]];
    for (NSNumber *v in performance.loadingTime) {
        [text appendFormat:@",%@", v];
    }
    [text appendString:@"\n"];
}
/**
 * @author hejunqiu, 16-03-30 11:03:21
 *
 * calculate average, max and min.
 *
 * @param array A array contains float value.
 *
 * @return Return a string such as "87,98,70"
 */
+ (NSString *)calculateStatistics:(NSArray<NSNumber *> *)array
{
    CGFloat average = 0;
    //    CGFloat max = CGFLOAT_MIN;
    //    CGFloat min = CGFLOAT_MAX;
    for (NSNumber *v in array) {
        average += v.floatValue;
        //        if (v.floatValue > max) {
        //            max = v.floatValue;
        //        }
        //        if (v.floatValue < min) {
        //            min = v.floatValue;
        //        }
    }
    //    return [NSString stringWithFormat:@"%f,%f,%f", average, max, min];
    if (array.count != 0) {
        average /= array.count;
    }
    return [NSString stringWithFormat:@"%f", average];
}
@end
