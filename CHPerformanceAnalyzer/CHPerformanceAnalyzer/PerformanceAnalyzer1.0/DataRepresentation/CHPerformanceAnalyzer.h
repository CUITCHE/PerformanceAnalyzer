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

NS_ASSUME_NONNULL_BEGIN

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
 * Start performance analysis enginer.
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
/**
 * @author hejunqiu, 16-07-20 15:07:51
 *
 * Register a Class to analyzer. If analyzer is going to analysis a view which is
 * member of the Class, analyzer will not analysis the view.
 *
 * @param aClass A Class object.
 */
- (void)registerSkipModuleWithClass:(Class)aClass;
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
- (id)statisticsWithType:(NSInteger)type ofKey:(nullable NSString *)moduleKey;

@end


@interface CHPerformanceAnalyzer (ExtensionMonitor) PA_CLASS_AVAILABLE(1.1)

/// Default to CHPAMonitorTypeNone.
@property (nonatomic, readonly) CHPAMonitorType monitorType;

/**
 * @author hejunqiu, 16-08-03 13:08:35
 *
 * Set the monitor type with threshold. Analyzer tell you until beyond threshold.
 *
 * 1. If monitorType is CHPAMonitorTypeNone, analyzer will close monitor.
 *
 * 2. If monitorType is CHPAMonitorTypeSQLExecute, threshold is NSTimeInterval type.
 *
 * 3. If monitorType is CHPAMonitorTypeUIRefreshInMainThread, threshold is BOOL type.
 * YES represents open and NO represnets close.
 *
 * @note If threshold is nil, analyzer will close the monitor of relative type.
 *
 * @param monitorType see CHPAMonitorType
 * @param threshold   An NSNumber object to represent the threshold.
 */
- (void)setMonitorType:(CHPAMonitorType)monitorType withThreshold:(nullable NSNumber *)threshold;

@end


@protocol CHPerformanceAnalyzerDelegate <NSObject>

@optional
/**
 * @author hejunqiu, 16-03-29 20:03:56
 *
 * Invoked when save completed.
 *
 * @param analyzer  A performance analyzer.
 * @param filePath  A file path indicate to save statistics data recent time. If
 * save failed or other error, it would be nil.
 */
- (void)performanceAnalyzer:(CHPerformanceAnalyzer  *)analyzer
       completeWithFilePath:(nullable NSString *)filePath;

/**
 * @author hejunqiu, 16-07-20 14:07:01
 *
 * Invoked when analyzer can't get vaild title of module.
 *
 * @param analyzer       A performance analyzer.
 * @param viewController An UIViewController object which is loading.
 *
 * @return Expect return a string contains module name.
 */
- (NSString *)performanceAnalyzer:(CHPerformanceAnalyzer *)analyzer
    titleMethodWithViewController:(UIViewController *)viewController;

/**
 * @author hejunqiu, 16-08-03 16:08:22
 *
 * If you opened extension monitor, you will receive messages about monitor type
 * after something triggered monitor's treshold which you've set.
 *
 * @param analyzer    A performance analyzer.
 * @param monitorType see CHPAMonitorType.
 * @param message     A message from analyzer.
 */
- (void)performanceAnalyzer:(CHPerformanceAnalyzer *)analyzer
                monitorType:(CHPAMonitorType)monitorType
                    message:(NSString *)message PA_API_AVAILABLE(1.1);
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

NS_ASSUME_NONNULL_END