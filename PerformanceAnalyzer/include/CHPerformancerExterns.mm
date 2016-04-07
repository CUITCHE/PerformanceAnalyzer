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
    [analyzer addObservered:self forKeyPath:@"navigationItem.title"];
    [self viewDidAppear_aop2:animated];
}

- (void)viewDidDisappear_aop:(BOOL)animated
{
    [self viewDidDisappear_aop:animated];
    CHPerformanceAnalyzer *analyzer = [CHPerformanceAnalyzer sharedPerformanceAnalyzer];
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