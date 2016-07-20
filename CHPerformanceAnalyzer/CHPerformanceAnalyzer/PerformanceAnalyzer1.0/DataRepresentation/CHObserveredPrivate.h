//
//  CHObserveredPrivate.h
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHObserveredPrivate : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, weak) NSObject *observered;
@property (nonatomic) BOOL active;

@end
