//
//  CHPerformanceAnalyzerWindow.h
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHGlobalDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CHPerformanceAnalyzerWindowDelegate;

@interface CHPerformanceAnalyzerWindow : UIWindow

@property (nonatomic, readonly) CHPerformanceAnalyzerShowType showType;

- (instancetype)initWithAnalyzerType:(CHPerformanceAnalyzerShowType)type frame:(CGRect)frame;

@property (nonatomic, strong) NSString *moduleTitleString;
@property (nonatomic, weak) id<CHPerformanceAnalyzerWindowDelegate> delegate;

- (void)setPageLoadingTimeWithValue:(NSTimeInterval)interval;
- (void)setMemoryWithValue:(CGFloat)usage;
- (void)setCPUWithValue:(CGFloat)cpuRate;
- (void)setFPSWithValue:(CGFloat)fps;

- (void)addSkipModuleWithClassName:(Class)aClass;
@end


#pragma mark - UIViewController Category (PageLoading)
@interface UIViewController (PageLoading)

- (void)loadView_aop;
- (void)viewDidAppear_aop:(BOOL)animated;

@end


@protocol CHPerformanceAnalyzerWindowDelegate <NSObject>

@required
- (void)viewControllerLoadingView:(UIViewController *)viewController;
- (void)viewControllerDidApper:(UIViewController *)viewController;

- (void)performanceAnalyzerWantStart:(CHPerformanceAnalyzerWindow *)analyzerWindow;
- (void)performanceAnalyzerWantStop:(CHPerformanceAnalyzerWindow *)analyzerWindow;
- (void)performanceAnalyzerWantSave:(CHPerformanceAnalyzerWindow *)analyzerWindow;

@end

NS_ASSUME_NONNULL_END