//
//  NSMutableArray+Stack.h
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArrayStack : NSObject

@end

@interface NSMutableArray<ObjectType> (Stack)

- (void)push:(ObjectType)obj;
- (ObjectType)pop;
- (void)popFromIndex:(NSUInteger)index;

@end
