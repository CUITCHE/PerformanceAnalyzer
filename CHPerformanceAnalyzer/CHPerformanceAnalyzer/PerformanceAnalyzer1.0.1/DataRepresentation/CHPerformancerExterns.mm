//
//  CHPerformancerExterns.m
//  MobileTools
//
//  Created by hejunqiu on 16/4/6.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import "CHPerformancerExterns.h"
#import "WebViewController.h"
#import "CHPerformanceAnalyzer.h"

@implementation CHPerformancerExterns

@end

@interface WebViewController (PageLoading)



@end

@implementation WebViewController (PageLoading)

- (void)loadView_aop2
{
    CHPerformanceAnalyzer *analyzer = [CHPerformanceAnalyzer sharedPerformanceAnalyzer];
    [analyzer addObservered:self forKeyPath:@"navigationItem.title"];
    [self loadView_aop2];
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
                          originalSelector:@selector(loadView)
                                    newSEL:@selector(loadView_aop2)];
    [analyzer registerLoadingRuleWithClass:[WebViewController class]
                          originalSelector:@selector(viewDidDisappear:)
                                    newSEL:@selector(viewDidDisappear_aop:)];
};

CHPerformanceAnalyzerShowType CHPerformanceAnalyzerShowTypeSetting = CHPerformanceAnalyzerShowTypeAll;

NSString *CHPerformanceAnalyzerApplicationDelegateClassName = @"AppDelegate";