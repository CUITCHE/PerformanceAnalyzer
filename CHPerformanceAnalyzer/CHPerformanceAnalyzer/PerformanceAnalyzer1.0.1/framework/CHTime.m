//
//  CHTime.m
//  MobileTools
//
//  Created by hejunqiu on 16/2/28.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import "CHTime.h"

@interface CHTime ()

@property (nonatomic) NSTimeInterval lastTick;
@property (nonatomic) NSProcessInfo *processInfo;
@property (nonatomic) NSTimeInterval curTick;
@end

@implementation CHTime

- (void)start
{
    if (!_processInfo) {
        _processInfo = [NSProcessInfo processInfo];
        _lastTick = [_processInfo systemUptime];
    }
}

- (void)restart
{
    _lastTick = [_processInfo systemUptime];
}

- (NSTimeInterval)elapse
{
    _curTick = [_processInfo systemUptime];
    NSTimeInterval interval = _curTick - _lastTick;
    _lastTick = _curTick;
    return interval;
}

- (NSTimeInterval)tick
{
    return [_processInfo systemUptime];
}

- (NSTimeInterval)interval
{
    _curTick = [_processInfo systemUptime];
    return _curTick - _lastTick;
}
@end
