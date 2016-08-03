//
//  NSMutableArray+Stack.m
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import "NSMutableArray+Stack.h"

@implementation NSMutableArrayStack

@end

@implementation NSMutableArray (Stack)

- (void)push:(id)obj
{
    [self addObject:obj];
}

- (id)pop
{
    id obj = nil;
    do {
        if (self.count == 0) {
            break;
        }
        obj = self.firstObject;
        [self removeObjectAtIndex:0];
    } while (0);
    return obj;
}

- (void)popFromIndex:(NSUInteger)index
{
    NSUInteger count = self.count;
    if (index >= count) {
        return;
    }
    NSRange range = NSMakeRange(index, count - index);
    [self removeObjectsInRange:range];
}

@end
