//
//  CHPerformanceAnalyzer.m
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import "CHPerformanceAnalyzer.h"
#import "CHPerformanceAnalyzerWindow.h"
#import "CHPerformanceDataPackager.h"
#import "NSMutableArray+Stack.h"
#import "CHObserveredPrivate.h"
#import "CHPerformanceData.h"
#include <objc/runtime.h>
#import "CHAOPManager.h"
#import "CHTime.h"

#if defined(__cplusplus)
extern "C" {
#endif
    NS_INLINE unsigned long long usageOfCurrentAPPMemory();
    NS_INLINE CGFloat usageOfCurrentAPPCPU();
    NS_INLINE NSString *PerformanceDataFilePath();
    NS_INLINE BOOL application_aop_didFinishLaunchingWithOptions(id self,
                                                                 SEL selector,
                                                                 UIApplication *application,
                                                                 NSDictionary *launchOptions);
    NSUInteger accurateInstanceMemoryReserved(id instance, BOOL containerDeep = NO);
    NS_INLINE id executeQuery_aop_withArgumentsInArray_orDictionary_orVAList(id self,
                                                                             SEL selector,
                                                                             NSString *sql,
                                                                             NSArray *arrayArgs,
                                                                             NSDictionary *dictionaryArgs,
                                                                             va_list args) PA_API_AVAILABLE(1.1);
    NS_INLINE BOOL executeUpdate_aop_error_withArgumentsInArray_orDictionary_orVAList(id self,
                                                                                      SEL selector,
                                                                                      NSString *sql,
                                                                                      NSError **outErr,
                                                                                      NSArray *arrayArgs,
                                                                                      NSDictionary *dictionaryArgs,
                                                                                      va_list args) PA_API_AVAILABLE(1.1);
    NS_INLINE void setNeedsLayout_aop(id self, SEL selector) PA_API_AVAILABLE(1.1);
    NS_INLINE void layoutIfNeeded_aop(id self, SEL selector) PA_API_AVAILABLE(1.1);
    NS_INLINE void setNeedsDisplay_aop(id self, SEL selector) PA_API_AVAILABLE(1.1);
    NS_INLINE void setNeedsDisplayInRect_aop(id self, SEL selector, CGRect rect) PA_API_AVAILABLE(1.1);
    NS_INLINE void setNeedsUpdateConstraints_aop(id self, SEL selector) PA_API_AVAILABLE(1.1);
#if defined(__cplusplus)
}
#endif

volatile void startPerformanceAnalyzer()
{}

/**
 * @author hejunqiu, 16-07-18 23:07:57
 *
 * One for multi use. The instanceButInternal as a global variable is used by
 * class CHPerformanceAnalyzerWindow. In order to save memory, the lambda expression
 * borrows instanceButInternal variable to complete initialze.
 *
 */
__weak CHPerformanceAnalyzerWindow *instanceButInternal = []() {
    Class cls = NSClassFromString(CHPerformanceAnalyzerApplicationDelegateClassName);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (!cls) {
        fprintf(stderr, "ERROR:The App Delegate:%s is invalid! Performance Analyzer start failed!\n",
                CHPerformanceAnalyzerApplicationDelegateClassName.UTF8String);
    } else {
        class_addMethod(cls,
                        @selector(application_aop:didFinishLaunchingWithOptions:),
                        (IMP)application_aop_didFinishLaunchingWithOptions,
                        "B@:@@");
        [CHAOPManager aopInstanceMethodWithOriClass:cls
                                             oriSEL:@selector(application:didFinishLaunchingWithOptions:)
                                           aopClass:cls
                                             aopSEL:@selector(application_aop:didFinishLaunchingWithOptions:)];
    }

    Class fmdatabaseClass = NSClassFromString(@"FMDatabase");
    if (!fmdatabaseClass) {
        fprintf(stderr, "Tip: Your project doesn't include FMDatabase framework. SQL Monitor will not be opened.\n");
    } else {
        class_addMethod(fmdatabaseClass,
                        @selector(executeQuery_aop:withArgumentsInArray:orDictionary:orVAList:),
                        (IMP)executeQuery_aop_withArgumentsInArray_orDictionary_orVAList,
                        "@@:@@@@");
        [CHAOPManager aopInstanceMethodWithOriClass:fmdatabaseClass
                                             oriSEL:@selector(executeQuery:withArgumentsInArray:orDictionary:orVAList:)
                                           aopClass:fmdatabaseClass
                                             aopSEL:@selector(executeQuery_aop:withArgumentsInArray:orDictionary:orVAList:)];
        class_addMethod(fmdatabaseClass,
                        @selector(executeUpdate_aop:error:withArgumentsInArray:orDictionary:orVAList:),
                        (IMP)executeUpdate_aop_error_withArgumentsInArray_orDictionary_orVAList,
                        "B@:@^@@@@");
    }

    Class viewClass = NSClassFromString(@"UIView");
    if (!viewClass) {
        fprintf(stderr, "Error: No UIView Class!");
    } else {
        class_addMethod(viewClass, @selector(setNeedsLayout_aop), (IMP)setNeedsLayout_aop, "v@:");
        [CHAOPManager aopInstanceMethodWithOriClass:viewClass
                                             oriSEL:@selector(setNeedsLayout)
                                           aopClass:viewClass
                                             aopSEL:@selector(setNeedsLayout_aop)];
        class_addMethod(viewClass, @selector(layoutIfNeeded_aop), (IMP)layoutIfNeeded_aop, "v@:");
        [CHAOPManager aopInstanceMethodWithOriClass:viewClass
                                             oriSEL:@selector(layoutIfNeeded)
                                           aopClass:viewClass
                                             aopSEL:@selector(layoutIfNeeded_aop)];
        class_addMethod(viewClass, @selector(setNeedsDisplay_aop), (IMP)setNeedsDisplay_aop, "v@:");
        [CHAOPManager aopInstanceMethodWithOriClass:viewClass
                                             oriSEL:@selector(setNeedsDisplay)
                                           aopClass:viewClass
                                             aopSEL:@selector(setNeedsDisplay_aop)];
        class_addMethod(viewClass, @selector(setNeedsDisplayInRect_aop:), (IMP)setNeedsDisplayInRect_aop, "v@:{CGRect=\"origin\"{CGPoint=\"x\"d\"y\"d}\"size\"{CGSize=\"width\"d\"height\"d}}");
        [CHAOPManager aopInstanceMethodWithOriClass:viewClass
                                             oriSEL:@selector(setNeedsDisplayInRect:)
                                           aopClass:viewClass
                                             aopSEL:@selector(setNeedsDisplayInRect_aop:)];
        class_addMethod(viewClass, @selector(setNeedsUpdateConstraints_aop), (IMP)setNeedsUpdateConstraints_aop, "v@:");
        [CHAOPManager aopInstanceMethodWithOriClass:viewClass
                                             oriSEL:@selector(setNeedsUpdateConstraints)
                                           aopClass:viewClass
                                             aopSEL:@selector(setNeedsUpdateConstraints_aop)];
    }
#pragma clang diagnostic pop
    return nil;
}();

struct __InternalMethodFlags {
    uint32_t needRecordMemoryIncrement   : 1;
    uint32_t needStatisticReservedMemory : 1;
    uint32_t methodFlagPerformanceAnalyzerCompleteWithFilePath          : 1;
    uint32_t methodFlagPerformanceAnalyzerTitleMethodWithViewController : 1;
    uint32_t methodFlagPerformanceAnalyzerMonitorTypeMessage            : 1;
};

@interface CHPerformanceAnalyzer () <CHPerformanceAnalyzerWindowDelegate>
{
    NSUInteger                  _fpsCount;
    CFTimeInterval              _fpsLastTime;
    CHTime *                    _loadingTime;
    NSUInteger                  _analyzerReserved;
    NSMutableArray<NSString *> *_moduleStack;
    struct __InternalMethodFlags                          _analyzerFlags;
    NSMutableArray<CHObserveredPrivate *> *               _registeredObservereds;
    NSMutableDictionary<NSString *, CHPerformanceData *> *_performanceData;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) CHPerformanceAnalyzerWindow *performanceWindow;

@property (nonatomic, strong) CADisplayLink *fpsDisplayLinker;
@property (nonatomic, strong) NSTimer *updater;

@property (nonatomic) CHPAMonitorType monitorType PA_API_AVAILABLE(1.1);
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *monitorTreshold PA_API_AVAILABLE(1.1);

- (void)monitorType:(CHPAMonitorType)monitorType
       monitorValue:(NSNumber *)value
            message:(NSDictionary *)message PA_API_AVAILABLE(1.1);

@end

@implementation CHPerformanceAnalyzer

#pragma mark - initializer
+ (instancetype)sharedPerformanceAnalyzer
{
    static CHPerformanceAnalyzer *instance = [CHPerformanceAnalyzer new];
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _analyzerFlags.needStatisticReservedMemory = YES;
        _performanceWindow = [[CHPerformanceAnalyzerWindow alloc] initWithAnalyzerType:CHPerformanceAnalyzerShowTypeSetting
                                                                                 frame:CGRectMake(5, 64, 310, 100)];
        _performanceWindow.delegate = self;
        instanceButInternal = _performanceWindow;

        _loadingTime = [[CHTime alloc] init];
        [_loadingTime start];

        _moduleStack = [NSMutableArray arrayWithCapacity:10];
        _performanceData = [NSMutableDictionary dictionaryWithCapacity:10];

        [self accurateMemoryReservedForInitial];
    }
    return self;
}

- (void)accurateMemoryReservedForInitial
{
    _analyzerReserved ^= _analyzerReserved;
    _analyzerReserved += accurateInstanceMemoryReserved(_loadingTime);
    _analyzerReserved += accurateInstanceMemoryReserved(_title);
    _analyzerReserved += accurateInstanceMemoryReserved(_performanceWindow);
}

- (NSUInteger)accurateMemoryReserved
{
    NSUInteger reserved = accurateInstanceMemoryReserved(_registeredObservereds) +
                          accurateInstanceMemoryReserved(_moduleStack, YES) +
                          accurateInstanceMemoryReserved(_performanceData, YES);
    return reserved + _analyzerReserved;
}

#pragma mark - Interface
- (void)startAnalysis
{
    [self stopAnalysis];
    _updater = [NSTimer timerWithTimeInterval:0.5
                                       target:self
                                     selector:@selector(onUpdaterTimeout:)
                                     userInfo:nil
                                      repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_updater forMode:UITrackingRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_updater forMode:NSDefaultRunLoopMode];
    [_updater fire];

    if (option_check(_performanceWindow.showType, CHPerformanceAnalyzerShowTypeFPS)) {
        _fpsDisplayLinker = [CADisplayLink displayLinkWithTarget:self selector:@selector(onFPSDisplayLinker:)];
        [_fpsDisplayLinker addToRunLoop:[NSRunLoop currentRunLoop] forMode:UITrackingRunLoopMode];
        [_fpsDisplayLinker addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    if (_analyzerFlags.needStatisticReservedMemory) {
        _analyzerReserved += accurateInstanceMemoryReserved(_updater);
        _analyzerReserved += accurateInstanceMemoryReserved(_fpsDisplayLinker);
        _analyzerFlags.needStatisticReservedMemory = 0;
    }

    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        self.performanceWindow.hidden = NO;
        [self.performanceWindow makeKeyAndVisible];
    });
}

- (void)stopAnalysis
{
    if (_updater.valid) {
        [_updater invalidate];
        _updater = nil;
    }
    [_fpsDisplayLinker invalidate];
    _fpsDisplayLinker = nil;

    self.performanceWindow.hidden = YES;
    [self.performanceWindow resignKeyWindow];

    [_moduleStack removeAllObjects];
    [_performanceData removeAllObjects];
    _fpsCount    = 0;
    _fpsLastTime = 0;
}

- (NSArray<NSString *> *)modulesOfStatistic
{
    return _performanceData.allKeys;
}

- (id)statisticsWithType:(NSInteger)type ofKey:(NSString *)moduleKey
{
    CHPerformanceData *d = [_performanceData valueForKey:moduleKey];
    NSArray<NSNumber *> *tmp = nil;
    if (d) {
        switch (type) {
            case CHPerformanceDataTypeCPU:
                tmp = d.cpu;
                break;
            case CHPerformanceDataTypeMemory:
                tmp = d.memory;
                break;
            case CHPerformanceDataTypeFPS:
                tmp = d.fps;
                break;
            case CHPerformanceDataTypeLoadingTime:
                tmp = d.loadingTime;
                break;
        }
    }
    return tmp;
}

#pragma mark - property
- (void)setPreferredSize:(CGSize)preferredSize
{
    if (!CGSizeEqualToSize(_performanceWindow.frame.size, preferredSize)) {
        _performanceWindow.frame = CGRect{.origin = _performanceWindow.frame.origin,
                                          .size   = preferredSize};
    }
}

- (void)setDelegate:(id<CHPerformanceAnalyzerDelegate>)delegate
{
    if (![_delegate isEqual:delegate]) {
        _analyzerFlags.methodFlagPerformanceAnalyzerCompleteWithFilePath = [_delegate respondsToSelector:@selector(performanceAnalyzer:completeWithFilePath:)];
        _analyzerFlags.methodFlagPerformanceAnalyzerTitleMethodWithViewController = [_delegate respondsToSelector:@selector(performanceAnalyzer:titleMethodWithViewController:)];
        _analyzerFlags.methodFlagPerformanceAnalyzerMonitorTypeMessage = [_delegate respondsToSelector:@selector(performanceAnalyzer:monitorType:message:)];
    }
}

- (NSMutableDictionary<NSNumber *, NSNumber *> *)monitorTreshold PA_API_AVAILABLE(1.1)
{
    if (!_monitorTreshold) {
        _monitorTreshold = [NSMutableDictionary dictionary];
    }
    return _monitorTreshold;
}

#pragma mark - Observered
- (void)addObservered:(NSObject *)observered forKeyPath:(NSString *)keyPath
{
    if (!_registeredObservereds) {
        _registeredObservereds = [NSMutableArray arrayWithCapacity:3];
    }
    [observered addObserver:self
                 forKeyPath:keyPath
                    options:NSKeyValueObservingOptionNew
                    context:nil];
    NSEnumerator<CHObserveredPrivate *> *enumerator = [_registeredObservereds objectEnumerator];
    CHObserveredPrivate *d = nil;
    while ((d = enumerator.nextObject)) { // find the CHObserveredPrivate instance to recycle use.
        if (!d.active) {
            d.active = YES;
            d.observered = observered;
            d.keyPath = keyPath;
            d.className = NSStringFromClass([observered class]);
            break;
        }
    }
    if (!d) {
        d            = [[CHObserveredPrivate alloc] init];
        d.observered = observered;
        d.keyPath    = keyPath;
        d.className  = NSStringFromClass([observered class]);
        d.active     = YES;
        [_registeredObservereds addObject:d];
    }
}

- (void)removeObservered:(NSObject *)observered forKeyPath:(NSString *)keyPath
{
    [observered removeObserver:self
                    forKeyPath:keyPath
                       context:nil];
    for (CHObserveredPrivate *d in _registeredObservereds) {
        if (d.observered == observered) {
            d.active = NO;
            break;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    for (CHObserveredPrivate *d in _registeredObservereds) {
        if (d.observered == object) {
            [self updatePageLoadingWithClassName:d.className
                             andUpdateModuleName:[change objectForKey:NSKeyValueChangeNewKey]];
            break;
        }
    }
}

#pragma mark -Rule
- (void)registerLoadingRuleWithClass:(Class)cls originalSelector:(SEL)oriSelector newSEL:(SEL)newSelector
{
    [CHAOPManager aopInstanceMethodWithOriClass:cls oriSEL:oriSelector
                                       aopClass:cls aopSEL:newSelector];
}

#pragma mark - Register
- (void)registerSkipModuleWithClass:(Class)aClass
{
    [_performanceWindow addSkipModuleWithClassName:aClass];
}

#pragma mark - Update
- (void)updatePageLoadingWithClassName:(NSString *)className
                   andUpdateModuleName:(NSString *)moduleName
{
    if (!moduleName || !className) {
        NSAssert(NO, @"Error param");
        return;
    }
    NSString *identifier = [NSString stringWithFormat:@"%@-%@", moduleName, className];
    NSUInteger index = [_moduleStack indexOfObject:identifier];
    if (index == NSNotFound) {
        self.title = identifier;
        if (option_check(_performanceWindow.showType, CHPerformanceAnalyzerShowTypePageLoading)) {
            NSTimeInterval interval = [_loadingTime interval];
            [_performanceWindow setPageLoadingTimeWithValue:interval];
            auto d = [self currentPerformanceData];
            [d addPerformanceData:@(interval)
                          forType:CHPerformanceDataTypeLoadingTime];
        }
    } else {
        [_moduleStack popFromIndex:index];
        self.title = identifier;
        [_performanceWindow setPageLoadingTimeWithValue:-1];
    }
}

- (void)setTitle:(NSString *)title
{
    if (![_title isEqualToString:title]) {
        _title = title.copy;
        _performanceWindow.moduleTitleString = title;
        id tmp = [_performanceData valueForKey:title];
        if (!tmp) {
            tmp = [CHPerformanceData performanceDataWithModuleName:title];
            [_performanceData setObject:tmp forKey:title];
            _analyzerFlags.needRecordMemoryIncrement = YES;
        } else {
            _analyzerFlags.needRecordMemoryIncrement = NO;
        }
        [_moduleStack push:title];
    }
}

- (CHPerformanceData *)currentPerformanceData
{
    return [_performanceData objectForKey:_title];
}

#pragma mark - Time Out
- (void)onUpdaterTimeout:(id)sender
{
    CHPerformanceData *cur = [self currentPerformanceData];

    if (option_check(_performanceWindow.showType, CHPerformanceAnalyzerShowTypeCPU)) {
        CGFloat value = usageOfCurrentAPPCPU();
        [cur addPerformanceData:@(value) forType:CHPerformanceDataTypeCPU];
        [_performanceWindow setCPUWithValue:value];
    }

    if (option_check(_performanceWindow.showType, CHPerformanceAnalyzerShowTypeMemory)) {
        CGFloat value = -1;
        if (_analyzerFlags.needRecordMemoryIncrement) {
            value = (usageOfCurrentAPPMemory() - [self accurateMemoryReserved]) / (1024 * 1024.0);
        }
        [cur addPerformanceData:@(value) forType:CHPerformanceDataTypeMemory];
        [_performanceWindow setMemoryWithValue:value];
    }
}

- (void)onFPSDisplayLinker:(CADisplayLink *)linker
{
    do {
        if (_fpsLastTime == 0) {
            _fpsLastTime = linker.timestamp;
            break;
        }
        ++_fpsCount;
        CFTimeInterval delta = linker.timestamp - _fpsLastTime;
        if (delta < 1) {
            break;
        }
        CGFloat fps = _fpsCount / delta;
        _fpsCount    = 0;
        _fpsLastTime = linker.timestamp;
        [_performanceWindow setFPSWithValue:fps];

        CHPerformanceData *cur = [self currentPerformanceData];
        [cur addPerformanceData:@(fps) forType:CHPerformanceDataTypeFPS];
    } while (0);
}

#pragma mark - CHPerformanceAnalyzerWindowDelegate
- (void)viewControllerLoadingView:(UIViewController *)viewController
{
    [_loadingTime restart];
}

- (void)viewControllerDidApper:(UIViewController *)viewController
{
    NSString *title = viewController.title;
    do {
        if (title) {
            break;
        }
        title = viewController.navigationItem.title;
        if (title) {
            break;
        }
        if (_analyzerFlags.methodFlagPerformanceAnalyzerTitleMethodWithViewController) {
            title = [_delegate performanceAnalyzer:self
                     titleMethodWithViewController:viewController];
        }
    } while (0);

    BOOL exists = NO;
    for (CHObserveredPrivate *d in _registeredObservereds) {
        if (viewController == d.observered) {
            exists = YES;
            break;
        }
    }
    if (!exists) {
        [self updatePageLoadingWithClassName:NSStringFromClass(viewController.class)
                         andUpdateModuleName:title];
    }
}

- (void)performanceAnalyzerWantStart:(CHPerformanceAnalyzerWindow *)analyzerWindow
{
    [self startAnalysis];
}

- (void)performanceAnalyzerWantStop:(CHPerformanceAnalyzerWindow *)analyzerWindow
{
    [self stopAnalysis];
}

- (void)performanceAnalyzerWantSave:(CHPerformanceAnalyzerWindow *)analyzerWindow
{
    NSMutableString *msg = [NSMutableString stringWithString:_performanceWindow.moduleTitleString];
    auto packager = [CHPerformanceDataPackager packagerWithPerformanceShowType:_performanceWindow.showType];
    packager.dataSource = _performanceData;
    NSString *text = [packager performanceDataLocalizedToCSV];
    NSError *error = nil;
    NSString *fullpath = [PerformanceDataFilePath() stringByAppendingPathComponent:@"performance.txt"];
    [text writeToFile:fullpath
           atomically:YES
             encoding:NSUTF8StringEncoding
                error:&error];
    if (error) {
        [msg appendString:@"(save Failed!)"];
        NSLog(@"%@", error);
    } else {
        [msg appendString:@"(save OK!)"];
        fullpath = nil;
    }
    if (_analyzerFlags.methodFlagPerformanceAnalyzerCompleteWithFilePath) {
        [_delegate performanceAnalyzer:self completeWithFilePath:fullpath];
    }
    _performanceWindow.moduleTitleString = msg;
}

#pragma mark - Class ExtensionMonitor
- (void)setMonitorType:(CHPAMonitorType)monitorType withThreshold:(NSNumber *)threshold PA_API_AVAILABLE(1.1)
{
    do {
        if (monitorType == CHPAMonitorTypeNone) {
            [self.monitorTreshold removeAllObjects];
            break;
        }
        if (!threshold) {
            [self.monitorTreshold removeObjectForKey:@(monitorType)];
        } else {
            [self.monitorTreshold setObject:@(monitorType) forKey:threshold];
        }
    } while (0);
}

#pragma mark - Monitor
- (void)monitorType:(CHPAMonitorType)monitorType
       monitorValue:(NSNumber *)value
            message:(NSDictionary *)message PA_API_AVAILABLE(1.1)
{
    switch (monitorType) {
        case CHPAMonitorTypeNone:
            NSAssert(NO, @"Logic error.");
            break;
        case CHPAMonitorTypeSQLExecute:
        {
            NSNumber *threshold = [self.monitorTreshold objectForKey:@(CHPAMonitorTypeSQLExecute)];
            if ([threshold compare:value] == NSOrderedAscending) {
                if (_analyzerFlags.methodFlagPerformanceAnalyzerMonitorTypeMessage) {
                    NSString *sql = message[@"s"];
                    NSString *type= message[@"t"];
                    NSString *msg = [NSString stringWithFormat:@"- SQL Monitor: %@ SQL(%@) use %@s. Please be careful.",
                                     type, sql, value];
                    [_delegate performanceAnalyzer:self monitorType:CHPAMonitorTypeSQLExecute message:msg];
                }
            }
        }
            break;
        case CHPAMonitorTypeUIRefreshInMainThread:
        {
            BOOL does = [[self.monitorTreshold objectForKey:@(CHPAMonitorTypeUIRefreshInMainThread)] boolValue];
            if (does && _analyzerFlags.methodFlagPerformanceAnalyzerMonitorTypeMessage && !value.boolValue) {
                id s = message[@"self"];
                NSString *m = message[@"method"];
                NSString *msg = [NSString stringWithFormat:@"- UI Monitor: %@ is not invoked in main thread at view<%@>."
                                 ,m, s];
                [_delegate performanceAnalyzer:self monitorType:CHPAMonitorTypeUIRefreshInMainThread message:msg];
            }
        }
            break;
        default:
            break;
    }
}
@end


#pragma mark - C Tools

#if defined(__cplusplus)
extern "C" {
#endif

#import <mach/mach.h>

NS_INLINE unsigned long long usageOfCurrentAPPMemory()
{
    static mach_task_basic_info_data_t taskInfo;
    static mach_msg_type_number_t infoCount = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         MACH_TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    return kernReturn != KERN_SUCCESS ? 0 : taskInfo.resident_size;
}

NS_INLINE CGFloat usageOfCurrentAPPCPU()
{
    // ref: http://stackoverflow.com/questions/8223348/ios-get-cpu-usage-from-application
    static kern_return_t kr;
    static task_info_data_t tinfo;
    static mach_msg_type_number_t task_info_count = TASK_INFO_MAX;

    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS)
        return -1;

    static thread_array_t         thread_list;
    static mach_msg_type_number_t thread_count;
    static thread_info_data_t     thinfo;
    static mach_msg_type_number_t thread_info_count;
    static thread_basic_info_t basic_info_th;

    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS)
        return -1;

    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;

    for (int j = 0; j < thread_count; ++j) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS)
            return -1;

        basic_info_th = (thread_basic_info_t)thinfo;
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
        }

    } // for each thread
    if (tot_cpu - 1 > 0.00000001) {
        tot_cpu = 1;
    }
    return tot_cpu * 100;
}

NS_INLINE NSString *PerformanceDataFilePath()
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask,
                                                YES) objectAtIndex:0];
}

NS_INLINE BOOL application_aop_didFinishLaunchingWithOptions(id self, SEL selector, UIApplication *application, NSDictionary *launchOptions)
{
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation     = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    invocation.selector = @selector(application_aop:didFinishLaunchingWithOptions:);
#pragma clang diagnostic pop
    void *app = (__bridge void *)application;
    [invocation setArgument:&app atIndex:2];

    void *lau = (__bridge void *)launchOptions;
    [invocation setArgument:&lau atIndex:3];
    [invocation invoke];
    BOOL retr = 0;
    [invocation getReturnValue:&retr];
    if (CHPerformanceAnalyzerAOPInitializer) {
        CHPerformanceAnalyzerAOPInitializer();
    }
    [[CHPerformanceAnalyzer sharedPerformanceAnalyzer] startAnalysis];
    return retr;
}

// AOP TO: - (FMResultSet *)executeQuery_aop:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;
NS_INLINE id executeQuery_aop_withArgumentsInArray_orDictionary_orVAList(id self,
                                                                         SEL selector,
                                                                         NSString *sql,
                                                                         NSArray *arrayArgs,
                                                                         NSDictionary *dictionaryArgs,
                                                                         va_list args) PA_API_AVAILABLE(1.1)
{
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation     = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    invocation.selector = @selector(executeQuery_aop:withArgumentsInArray:orDictionary:orVAList:);
#pragma clang diagnostic pop
    void *_sql = (__bridge void *)sql;
    [invocation setArgument:_sql atIndex:2];

    void *_arrayArgs = (__bridge void *)arrayArgs;
    [invocation setArgument:&_arrayArgs atIndex:3];

    void *_dictionaryArgs = (__bridge void *)dictionaryArgs;
    [invocation setArgument:&_dictionaryArgs atIndex:4];

    [invocation setArgument:&args atIndex:5];

    static CHTime *click = [](){
        CHTime *click = [[CHTime alloc] init];
        [click start];
        return click;
    }();

    // clean click
    [click restart];
    // invoke and get return value
    [invocation invoke];
    id ret = nil;
    [invocation getReturnValue:&ret];
    NSTimeInterval interval = [click interval];
    NSDictionary *message = @{@"s" : sql ?: @"Empty SQL",
                              @"t" : @"query"};
    [[CHPerformanceAnalyzer sharedPerformanceAnalyzer] monitorType:CHPAMonitorTypeSQLExecute
                                                      monitorValue:@(interval)
                                                           message:message];
    return ret;
}

// AOP TO:  - (BOOL)executeUpdate_aop:(NSString*)sql error:(NSError**)outErr withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;
NS_INLINE BOOL executeUpdate_aop_error_withArgumentsInArray_orDictionary_orVAList(id self,
                                                                                  SEL selector,
                                                                                  NSString *sql,
                                                                                  NSError **outErr,
                                                                                  NSArray *arrayArgs,
                                                                                  NSDictionary *dictionaryArgs,
                                                                                  va_list args) PA_API_AVAILABLE(1.1)
{
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation     = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    invocation.selector = @selector(executeUpdate_aop:error:withArgumentsInArray:orDictionary:orVAList:);
#pragma clang diagnostic pop
    void *_sql = (__bridge void *)sql;
    [invocation setArgument:_sql atIndex:2];

    // TODO: need test!
    [invocation setArgument:outErr atIndex:3];

    void *_arrayArgs = (__bridge void *)arrayArgs;
    [invocation setArgument:&_arrayArgs atIndex:4];

    void *_dictionaryArgs = (__bridge void *)dictionaryArgs;
    [invocation setArgument:&_dictionaryArgs atIndex:5];

    [invocation setArgument:&args atIndex:6];

    static CHTime *click = [](){
        CHTime *click = [[CHTime alloc] init];
        [click start];
        return click;
    }();

    // clean click
    [click restart];
    // invoke and get return value
    [invocation invoke];
    BOOL ret = 0;
    [invocation getReturnValue:&ret];
    NSTimeInterval interval = [click interval];
    NSDictionary *message = @{@"s" : sql ?: @"Empty SQL",
                              @"t" : @"update"};
    [[CHPerformanceAnalyzer sharedPerformanceAnalyzer] monitorType:CHPAMonitorTypeSQLExecute
                                                      monitorValue:@(interval)
                                                           message:message];
    return ret;
}

// AOP TO: - (void)setNeedsLayout;
NS_INLINE void setNeedsLayout_aop(id self, SEL selector) PA_API_AVAILABLE(1.1)
{
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation     = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    invocation.selector = @selector(setNeedsLayout_aop);
#pragma clang diagnostic pop
    [invocation invoke];

    BOOL isMainThread = [NSThread isMainThread];
    if (!isMainThread) {
        NSDictionary *message = @{@"self"   : self,
                                  @"method" : @"- (void)setNeedsLayout"};
        [[CHPerformanceAnalyzer sharedPerformanceAnalyzer] monitorType:CHPAMonitorTypeUIRefreshInMainThread monitorValue:@(isMainThread) message:message];
    }
}

// AOP TO: - (void)layoutIfNeeded;
NS_INLINE void layoutIfNeeded_aop(id self, SEL selector) PA_API_AVAILABLE(1.1)
{
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation     = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    invocation.selector = @selector(layoutIfNeeded_aop);
#pragma clang diagnostic pop
    [invocation invoke];

    BOOL isMainThread = [NSThread isMainThread];
    if (!isMainThread) {
        NSDictionary *message = @{@"self"   : self,
                                  @"method" : @"- (void)layoutIfNeeded"};
        [[CHPerformanceAnalyzer sharedPerformanceAnalyzer] monitorType:CHPAMonitorTypeUIRefreshInMainThread monitorValue:@(isMainThread) message:message];
    }
}

// AOP TO: - (void)setNeedsDisplay;
NS_INLINE void setNeedsDisplay_aop(id self, SEL selector) PA_API_AVAILABLE(1.1)
{
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation     = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    invocation.selector = @selector(setNeedsDisplay_aop);
#pragma clang diagnostic pop
    [invocation invoke];

    BOOL isMainThread = [NSThread isMainThread];
    if (!isMainThread) {
        NSDictionary *message = @{@"self"   : self,
                                  @"method" : @"- (void)setNeedsDisplay"};
        [[CHPerformanceAnalyzer sharedPerformanceAnalyzer] monitorType:CHPAMonitorTypeUIRefreshInMainThread monitorValue:@(isMainThread) message:message];
    }
}

// AOP TO: - (void)setNeedsDisplayInRect:(CGRect)rect;
NS_INLINE void setNeedsDisplayInRect_aop(id self, SEL selector, CGRect rect) PA_API_AVAILABLE(1.1)
{
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation     = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    invocation.selector = @selector(setNeedsDisplayInRect_aop:);
#pragma clang diagnostic pop
    [invocation setArgument:&rect atIndex:2];
    [invocation invoke];

    BOOL isMainThread = [NSThread isMainThread];
    if (!isMainThread) {
        NSDictionary *message = @{@"self"   : self,
                                  @"method" : @"- (void)setNeedsDisplayInRect:"};
        [[CHPerformanceAnalyzer sharedPerformanceAnalyzer] monitorType:CHPAMonitorTypeUIRefreshInMainThread monitorValue:@(isMainThread) message:message];
    }
}

// AOP TO: - (void)setNeedsUpdateConstraints
NS_INLINE void setNeedsUpdateConstraints_aop(id self, SEL selector) PA_API_AVAILABLE(1.1)
{
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation     = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    invocation.selector = @selector(setNeedsUpdateConstraints_aop);
#pragma clang diagnostic pop
    [invocation invoke];

    BOOL isMainThread = [NSThread isMainThread];
    if (!isMainThread) {
        NSDictionary *message = message = @{@"self"   : self,
                                            @"method" : @"- (void)setNeedsUpdateConstraints"};
        [[CHPerformanceAnalyzer sharedPerformanceAnalyzer] monitorType:CHPAMonitorTypeUIRefreshInMainThread monitorValue:@(isMainThread) message:message];
    }
}


#include <malloc/malloc.h>

union __save_count_ivar__ {
    uint32_t count;
    Ivar *p;
};

NS_INLINE NSInteger accurateContainerMemoryReserved(id container);

NSUInteger accurateInstanceMemoryReserved(id instance, BOOL containerDeep/* = NO*/)
{
#define POINTER_SIZE sizeof(void*)
    NSUInteger reserved = 0;
    do {
        if (!instance) {
            reserved = POINTER_SIZE;
            break;
        }
        if ([instance isMemberOfClass:[NSObject class]]) {
            break;
        }
        if (object_isClass(instance)) { // This is a class object or meta-class
            break;
        }
        void *c_instance = (__bridge void*)instance;
        reserved = malloc_size(c_instance);
        union __save_count_ivar__ u;
        u.count = 0;
        Class cls = [instance class];
        Ivar *ivars = class_copyIvarList(cls, &u.count);
        if (!ivars) { // NULL, but also calculate pointer size
            reserved += POINTER_SIZE;
            break;
        }
        Ivar *ivarsEnd = ivars + u.count;
        u.p = ivars - 1;
        while (++u.p < ivarsEnd) {
            const char *type = ivar_getTypeEncoding(*u.p);
            if (type[0] == '@') {
                if (type[1] == '\"' && type[2] != '<') { // This is a delegate, avoid to recycle.
                    NSString *key = [NSString stringWithUTF8String:ivar_getName(*u.p)];
                    id value = [instance valueForKey:key];
                    reserved += accurateInstanceMemoryReserved(value, containerDeep);
                }
            } else if (type[0] == '^') { // get malloc size of C/C++ style pointer
                auto d = reinterpret_cast<NSInteger>(c_instance);
                const void *ptr = reinterpret_cast<void *>(d + ivar_getOffset(*u.p));
                reserved += malloc_size(ptr);
            }
        }
        free(ivars);
        if (containerDeep) {
            reserved = accurateContainerMemoryReserved(instance);
        }
    } while (0);
    return reserved;
}

NS_INLINE NSInteger accurateContainerMemoryReserved(id container)
{
    NSUInteger reserved = 0;
    // check whether instance is array or dictionary or not.
    if ([container respondsToSelector:@selector(objectEnumerator)]) {
        NSEnumerator *enumerator = [container performSelector:@selector(objectEnumerator)];
        id obj = nil;
        while ((obj = enumerator.nextObject)) {
            reserved += accurateInstanceMemoryReserved(obj);
        }
    }
    return reserved;
}
#if defined(__cplusplus)
}
#endif