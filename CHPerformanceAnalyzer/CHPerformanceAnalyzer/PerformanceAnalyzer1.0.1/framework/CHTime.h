//
//  CHTime.h
//  MobileTools
//
//  Created by hejunqiu on 16/2/28.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHTime : NSObject

/**
 * @author hejunqiu, 16-03-24 15:03:38
 *
 * @note You must invoke this method when you create a CHTimer instance.
 */
- (void)start;
- (void)restart;

/// 计算上一次调用start/restart/elapse后到现在的时间间隔，会更新内部计数器
@property (readonly) NSTimeInterval elapse;
/// 获取设备从启动后经历的时间，不会更新内部计数器
@property (readonly) NSTimeInterval tick;

/// 计算上一次调用start/restart后到现在的时间间隔
@property (readonly) NSTimeInterval interval;
@end
