//
//  CHPerformanceAnalyzer.h
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/3/28.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHPerformanceAnalyzerDelegate;

typedef NS_OPTIONS(NSUInteger, CHPerformanceAnalyzerShowType) {
    CHPerformanceAnalyzerShowTypeCPU = 1,
    CHPerformanceAnalyzerShowTypeMemory = 1 << 1,
    CHPerformanceAnalyzerShowTypePageLoading = 1 << 2,
    CHPerformanceAnalyzerShowTypeFPS = 1 << 3,
    CHPerformanceAnalyzerShowTypeAll = CHPerformanceAnalyzerShowTypeCPU | CHPerformanceAnalyzerShowTypeMemory | CHPerformanceAnalyzerShowTypePageLoading | CHPerformanceAnalyzerShowTypeFPS
};

/**
 * @author hejunqiu, 16-03-29 20:03:35
 *
 * Create a window on the top(1<<5) view. Its frame is {(5, 64), (310, 100)}.
 *
 * Method: - (void)startAnalysis, start the enginer. Generally, the window will show
 * after 1 seconds when you invoke this method. So Be Carefully.
 *
 * Method: - (void)stopAnalysis, stop the enginer. The method will clean all of
 * statistics data.
 *
 * Feature 0: You can shake the device to start or stop the enginer.
 *
 * Feature 1: You can tap the window twice throught two fingers to save current
 * statistics data.
 *
 * You can set CHPerformanceAnalyzerShowTypeSetting before you invoke + (instancetype)sharedPerformanceAnalyzer
 * first time to change what enginer should show statistics terms.
 *
 * There are some analysis modules:
 *
 * 1.Default. Just invoke start and stop method.(You may need not to do it)
 *
 * 2.Register modules. you can custom some methods by AOP to indicate the END of page
 * loading. However you should not to custom BEGIN of page loading, it is used by
 * analyzer defualtly.
 *
 */
@interface CHPerformanceAnalyzer : UIWindow

@property (nonatomic, weak) id<CHPerformanceAnalyzerDelegate> delegate;
@property (nonatomic, readonly) CHPerformanceAnalyzerShowType type;
/// modules in skipModules will be ignore.
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *skipModules;

+ (instancetype)sharedPerformanceAnalyzer;
- (instancetype)init NS_UNAVAILABLE;

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
 * @author hejunqiu, 16-04-07 11:04:31
 *
 * A method which inverses the '- (void)addObserver:forKeyPath:options:context:'.
 * Observered gives its keyPath to analyzer so that analyzer will receive the change
 * when observered's keyPath changed.
 *
 * @param observered A NSObject.
 * @param keyPath    keyPath of property.
 */
- (void)addObservered:(NSObject *)observered forKeyPath:(NSString *)keyPath;

/**
 * @author hejunqiu, 16-04-07 11:04:21
 *
 * A method which inverses the '- (void)removeObserver:forKeyPath:context:'.
 *
 * @param observered A NSObject.
 * @param keyPath    keyPath of property.
 */
- (void)removeObservered:(NSObject *)observered forKeyPath:(NSString *)keyPath;

@end


@interface CHPerformanceAnalyzer (Update)

- (void)updatePageLoadingWithClassName:(NSString *)className
                   andUpdateModuleName:(NSString *)moduleName;
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
 * If your project's app delegate class is not it, You should set it before you
 * invoke + (instancetype)sharedPerformanceAnalyzer for first time.
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

@protocol CHPerformanceAnalyzerDelegate <NSObject>

/**
 * @author hejunqiu, 16-03-29 20:03:56
 *
 * Invoked when save completed.
 *
 * @param analysiser A performance analyzer.
 * @param filePath   A file path indicate to save statistics data recent time. If
 * save failed or other error, it would be nil.
 */
- (void)performanceAnalysis:(CHPerformanceAnalyzer *)analysiser completeWithFilePath:(NSString *)filePath;

@end
