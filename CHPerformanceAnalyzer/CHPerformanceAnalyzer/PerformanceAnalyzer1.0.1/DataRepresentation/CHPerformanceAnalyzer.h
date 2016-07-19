//
//  CHPerformanceAnalyzer.h
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGeometry.h>
#import "CHGlobalDefines.h"

@protocol CHPerformanceAnalyzerDelegate;
@class UIViewController;

@interface CHPerformanceAnalyzer : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)sharedPerformanceAnalyzer;

@property (nonatomic) CGSize preferredSize;
@property (nonatomic, weak) id<CHPerformanceAnalyzerDelegate> delegate;

/**
 * @author hejunqiu, 16-03-29 11:03:07
 *
 * Start performance analysis enginer. The method will return
 */
- (void)startAnalysis;

/**
 * @author hejunqiu, 16-03-29 19:03:21
 *
 * Stop performance analysis enginer and clear statistics data.
 */
- (void)stopAnalysis;

- (void)addObservered:(NSObject *)observered forKeyPath:(NSString *)keyPath;
- (void)removeObservered:(NSObject *)observered forKeyPath:(NSString *)keyPath;

/**
 * @author hejunqiu, 16-04-05 18:04:35
 *
 * You can make a rule that indicates a view controller completed loading. This
 * method use AOP to implement.
 *
 * @param cls         A Class that is sub class of UIViewController.
 * @param oriSelector The original selector indicates that the view controller has
 * completed loading.
 * @param newSelector The new selector AOPed oriSelector. Both are instance method
 * of cls.
 */
- (void)registerLoadingRuleWithClass:(Class)cls
                    originalSelector:(SEL)oriSelector
                              newSEL:(SEL)newSelector;

@end


@interface CHPerformanceAnalyzer (Update)

- (void)updatePageLoadingWithClassName:(NSString *)className
                   andUpdateModuleName:(NSString *)moduleName;
@end

@interface CHPerformanceAnalyzer (StatisticResult)

@property (nonatomic, strong, readonly) NSArray<NSString *> *modulesOfStatistic;

/**
 * @author hejunqiu, 16-07-18 23:07:31
 *
 * Return an array contained NSNumber object. There is id type for common. Because
 * we may add new type for return.
 *
 * @param type      See CHPerformanceDataType.
 * @param moduleKey A key of module which comes from modulesOfStatistic property.
 *
 * @return Maybe an array contained NSNumber object.
 */
- (id)statisticsWithType:(NSInteger)type ofKey:(NSString *)moduleKey;

@end


@protocol CHPerformanceAnalyzerDelegate <NSObject>

/**
 * @author hejunqiu, 16-03-29 20:03:56
 *
 * Invoked when save completed.
 *
 * @param analyzer  A performance analyzer.
 * @param filePath  A file path indicate to save statistics data recent time. If
 * save failed or other error, it would be nil.
 */
- (void)performanceAnalyzer:(CHPerformanceAnalyzer *)analyzer
       completeWithFilePath:(NSString *)filePath;

- (NSString *)performanceAnalyzer:(CHPerformanceAnalyzer *)analyzer
    titleMethodWithViewController:(UIViewController *)viewController;
@end

/**
 * @author hejunqiu, 16-03-29 19:03:35
 *
 * You can set it before you invoke + (instancetype)sharedPerformanceAnalyzer.
 *
 * Default to CHPerformanceAnalyzerShowTypeAll.
 * @note Once you invoke + (instancetype)sharedPerformanceAnalyzer, it's useless
 * for CHPerformanceAnalyzerShowTypeSetting any changes.
 */
FOUNDATION_EXTERN CHPerformanceAnalyzerShowType CHPerformanceAnalyzerShowTypeSetting;

/**
 * @author hejunqiu, 16-03-30 15:03:33
 *
 * Defaultly You must set it at any where such as at your AppDelegate.m.
 * @code
 * NSString *CHPerformanceAnalyzerApplicationDelegateClassName = @"AppDelegate";
 * @endcode
 * If your project's app delegate class is not it, You
 * can set it before you invoke + (instancetype)sharedPerformanceAnalyzer for first
 * time.
 */
FOUNDATION_EXTERN NSString *CHPerformanceAnalyzerApplicationDelegateClassName;

/**
 * @author hejunqiu, 16-04-06 15:04:29
 *
 * You'd better implement it. It is used by analyzer to complete AOP init before
 * analyzer start.
 */
FOUNDATION_EXTERN void(^CHPerformanceAnalyzerAOPInitializer)();

/**
 * @author hejunqiu, 16-04-07 11:04:56
 *
 * Open the static library. The method is empty so that it will not do anything.
 * If you want not to import 'CHPerformanceAnalyzer.h', just declare this method
 * and invoke it in main function of main.mm file.
 *
 * @return void
 */
extern volatile void startPerformanceAnalyzer();
