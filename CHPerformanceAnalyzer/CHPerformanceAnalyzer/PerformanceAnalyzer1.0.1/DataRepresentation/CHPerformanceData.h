//
//  CHPerformanceData.h
//  MobileTools
//
//  Created by hejunqiu on 16/3/29.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CHPerformanceDataType) {
    CHPerformanceDataTypeCPU,
    CHPerformanceDataTypeMemory,
    CHPerformanceDataTypeFPS,
    CHPerformanceDataTypeLoadingTime
};

@interface CHPerformanceData : NSObject

@property (nonatomic, strong, readonly) NSString *moduleName;

@property (nonatomic, copy, readonly) NSArray<NSNumber *> *cpu;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *memory;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *fps;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *loadingTime;

+ (instancetype)performanceDataWithModuleName:(NSString *)moduleName;

/**
 * @author hejunqiu, 16-03-29 13:03:35
 *
 * Add performance data to property[cpu, memory, fps, loadingTime];
 *
 * @param performance A NSNumber value. It must not be nil.
 * @param type        Only accept string: cpu, memory, fps, loadingTime.
 */
- (void)addPerformanceData:(NSNumber *)performance forType:(CHPerformanceDataType)type;

@end
