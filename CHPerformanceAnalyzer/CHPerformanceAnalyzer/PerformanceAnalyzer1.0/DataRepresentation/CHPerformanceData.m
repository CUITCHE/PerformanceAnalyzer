//
//  CHPerformanceData.m
//  MobileTools
//
//  Created by hejunqiu on 16/3/29.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import "CHPerformanceData.h"
#include <malloc/malloc.h>

@interface CHPerformanceData ()

@property (nonatomic, strong) NSString *moduleName;

@property (nonatomic, copy) NSMutableArray<NSNumber *> *cpu;
@property (nonatomic, copy) NSMutableArray<NSNumber *> *memory;
@property (nonatomic, copy) NSMutableArray<NSNumber *> *fps;
@property (nonatomic, copy) NSMutableArray<NSNumber *> *loadingTime;

@end

@implementation CHPerformanceData

- (NSString *)description
{
    NSDictionary *dict = @{@"Module"     : _moduleName,
                           @"CPU"        : _cpu,
                           @"Memory"     : _moduleName,
                           @"FPS"        : _fps,
                           @"LoadingTime": _loadingTime};
    return [NSString stringWithFormat:@"%@", dict];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cpu         = [NSMutableArray array];
        _memory      = [NSMutableArray array];
        _fps         = [NSMutableArray array];
        _loadingTime = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)performanceDataWithModuleName:(NSString *)moduleName
{
    CHPerformanceData *obj = [[CHPerformanceData alloc] init];
    obj.moduleName = moduleName;
    return obj;
}

- (void)addPerformanceData:(NSNumber *)performance forType:(CHPerformanceDataType)type
{
    switch (type) {
        case CHPerformanceDataTypeCPU:
            [_cpu addObject:performance];
            break;
        case CHPerformanceDataTypeMemory:
            [_memory addObject:performance];
            break;
        case CHPerformanceDataTypeFPS:
            [_fps addObject:performance];
            break;
        case CHPerformanceDataTypeLoadingTime:
            [_loadingTime addObject:performance];
            break;
    }
}

@end
