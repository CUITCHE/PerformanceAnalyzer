//
//  CHPerformanceDataPackager.h
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHPerformanceData;

@interface CHPerformanceDataPackager : NSObject

@property (nonatomic, strong) NSDictionary<NSString *, CHPerformanceData *> *dataSource;

+ (instancetype)packagerWithPerformanceShowType:(NSInteger)type;
- (NSString *)performanceDataLocalizedToCSV;

@end
