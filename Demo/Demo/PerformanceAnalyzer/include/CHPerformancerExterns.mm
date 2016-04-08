//
//  CHPerformancerExterns.m
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/4/6.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import "CHPerformancerExterns.h"
#import "CHPerformanceAnalyzer.h"
#import "WebViewController.h"

@implementation CHPerformancerExterns

@end


@interface WebViewController (PageLoading)

@end

@implementation WebViewController (PageLoading)

- (void)viewDidAppear_aop2:(BOOL)animated
{
    CHPerformanceAnalyzer *analyzer = [CHPerformanceAnalyzer sharedPerformanceAnalyzer];
    // 反观察者模式，让analyzer成为这个'self'的观察者，去关注属性路径'navigationItem.title'
    [analyzer addObservered:self forKeyPath:@"navigationItem.title"];
    // 这句只能在上面的后面，颠倒位置将不会正确统计信息
    [self viewDidAppear_aop2:animated];
}

- (void)viewDidDisappear_aop:(BOOL)animated
{
    [self viewDidDisappear_aop:animated];
    CHPerformanceAnalyzer *analyzer = [CHPerformanceAnalyzer sharedPerformanceAnalyzer];
    // 这句要与'[analyzer addObservered:self forKeyPath:@"navigationItem.title"];'成对出现，否则将会抛出异常，因为底层的实现就是观察者模式。
    [analyzer removeObservered:self forKeyPath:@"navigationItem.title"];
}

@end

void(^CHPerformanceAnalyzerAOPInitializer)() = ^{
    CHPerformanceAnalyzer *analyzer = [CHPerformanceAnalyzer sharedPerformanceAnalyzer];
    [analyzer registerLoadingRuleWithClass:[WebViewController class]
                          originalSelector:@selector(viewDidAppear:)
                                    newSEL:@selector(viewDidAppear_aop2:)];
    [analyzer registerLoadingRuleWithClass:[WebViewController class]
                          originalSelector:@selector(viewDidDisappear:)
                                    newSEL:@selector(viewDidDisappear_aop:)];
};

NSString *CHPerformanceAnalyzerApplicationDelegateClassName = @"AppDelegate";
CHPerformanceAnalyzerShowType CHPerformanceAnalyzerShowTypeSetting = CHPerformanceAnalyzerShowTypeAll;