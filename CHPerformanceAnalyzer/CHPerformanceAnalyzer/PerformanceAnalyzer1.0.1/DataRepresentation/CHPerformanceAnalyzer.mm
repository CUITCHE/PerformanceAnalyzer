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
    NS_INLINE BOOL application_aop_didFinishLaunchingWithOptions(id self, SEL selector, UIApplication *application, NSDictionary *launchOptions);
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
    do {
        Class cls = NSClassFromString(CHPerformanceAnalyzerApplicationDelegateClassName);
        if (!cls) {
            fprintf(stderr, "ERROR:The App Delegate:%s is invalid! Performance Analyzer start failed!\n",
                    CHPerformanceAnalyzerApplicationDelegateClassName.UTF8String);
            break;
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        class_addMethod(cls,
                        @selector(application_aop:didFinishLaunchingWithOptions:),
                        (IMP)application_aop_didFinishLaunchingWithOptions,
                        "B@:@@");
        [CHAOPManager aopInstanceMethodWithOriClass:cls
                                             oriSEL:@selector(application:didFinishLaunchingWithOptions:)
                                           aopClass:cls
                                             aopSEL:@selector(application_aop:didFinishLaunchingWithOptions:)];
#pragma clang diagnostic pop
    } while(0);

    return nil;
}();

struct __InternalMethodFlags {
    uint32_t needRecordMemoryIncrement   : 1;
    uint32_t needStatisticReservedMemory : 1;
    uint32_t methodFlagPerformanceAnalyzerCompleteWithFilePath : 1;
    uint32_t methodFlagPerformanceAnalyzerTitleMethodWithViewController : 1;
};

@interface CHPerformanceAnalyzer () <CHPerformanceAnalyzerWindowDelegate>
{
    struct __InternalMethodFlags _analyzerFlags;
    NSMutableArray<CHObserveredPrivate *> *_registeredObservereds;
    CHTime *_loadingTime;
    NSMutableArray<NSString *> *_moduleStack;
    NSMutableDictionary<NSString *, CHPerformanceData *> *_performanceData;
    NSUInteger _analyzerReserved;
}

@property (nonatomic, strong) CHPerformanceAnalyzerWindow *performanceWindow;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) CADisplayLink *fpsDisplayLinker;
@property (nonatomic, strong) NSTimer *updater;

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
    _analyzerReserved += accurateInstanceMemoryReserved(_loadingTime);
    _analyzerReserved += accurateInstanceMemoryReserved(_title);
    _analyzerReserved += accurateInstanceMemoryReserved(_performanceWindow);
}

- (NSUInteger)accurateMemoryReserved
{
    NSUInteger reserved = accurateInstanceMemoryReserved(_registeredObservereds) +
                          accurateInstanceMemoryReserved(_moduleStack) +
                          accurateInstanceMemoryReserved(_performanceData);
    return reserved;
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
}

- (NSArray<NSString *> *)modulesOfStatistic
{
    return _performanceData.allKeys;
}

- (id)statisticsWithType:(NSInteger)type ofKey:(NSString *)moduleKey
{
    CHPerformanceData *d = [_performanceData valueForKey:moduleKey];
    NSArray<NSNumber *> *tmp = nil;
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
    }
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
    CHObserveredPrivate *d = enumerator.nextObject;
    while (d) { // find the CHObserveredPrivate instance to recycle use.
        if (!d.active) {
            d.active = YES;
            d.observered = observered;
            d.keyPath = keyPath;
            d.className = NSStringFromClass([observered class]);
            break;
        }
        d = enumerator.nextObject;
    }
    if (!d) {
        CHObserveredPrivate *newObj = [[CHObserveredPrivate alloc] init];
        newObj.observered = observered;
        newObj.keyPath = keyPath;
        newObj.className = NSStringFromClass([observered class]);
        newObj.active = YES;
        [_registeredObservereds addObject:newObj];
    }
}

- (void)removeObservered:(NSObject *)observered forKeyPath:(NSString *)keyPath
{
    [observered removeObserver:self
                    forKeyPath:keyPath
                       context:nil];
    NSEnumerator<CHObserveredPrivate *> *enumerator = [_registeredObservereds objectEnumerator];
    CHObserveredPrivate *d = enumerator.nextObject;
    while (d) {
        if (d.observered == observered) {
            d.active = NO;
            break;
        }
        d = enumerator.nextObject;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSEnumerator<CHObserveredPrivate *> *enumerator = [_registeredObservereds objectEnumerator];
    CHObserveredPrivate *d = enumerator.nextObject;
    while (d) {
        if (d.observered == object) {
            [self updatePageLoadingWithClassName:d.className
                             andUpdateModuleName:[change objectForKey:NSKeyValueChangeNewKey]];
            break;
        }
        d = enumerator.nextObject;
    }
}

#pragma mark -Rule
- (void)registerLoadingRuleWithClass:(Class)cls originalSelector:(SEL)oriSelector newSEL:(SEL)newSelector
{
    [CHAOPManager aopInstanceMethodWithOriClass:cls oriSEL:oriSelector
                                       aopClass:cls aopSEL:newSelector];
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
        self.title = identifier; // 本句不能和else分支的合并为一句拿到if-else外，这里处理的是逻辑问题，步骤不可少
        if (option_check(_performanceWindow.showType, CHPerformanceAnalyzerShowTypePageLoading)) {
            NSTimeInterval interval = [_loadingTime interval];
            [_performanceWindow setPageLoadingTimeWithValue:interval];
            [[self currentPerformanceData] addPerformanceData:@(interval) forType:CHPerformanceDataTypeLoadingTime];
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
            value = (usageOfCurrentAPPMemory() - 0) / (1024 * 1024.0);
        }
        [cur addPerformanceData:@(value) forType:CHPerformanceDataTypeMemory];
        [_performanceWindow setMemoryWithValue:value];
    }
}

- (void)onFPSDisplayLinker:(CADisplayLink *)linker
{
    static CFTimeInterval lastTime = 0;
    static NSUInteger count = 0;
    do {
        if (lastTime == 0) {
            lastTime = linker.timestamp;
            break;
        }
        ++count;
        CFTimeInterval delta = linker.timestamp - lastTime;
        if (delta < 1) {
            break;
        }
        CGFloat fps = count / delta;
        count = 0;
        lastTime = linker.timestamp;
        [_performanceWindow setFPSWithValue:fps];

        CHPerformanceData *cur = [self currentPerformanceData];
        [cur addPerformanceData:@(fps) forType:CHPerformanceDataTypeFPS];
    } while (0);
}

#pragma mark - CHPerformanceAnalyzerDelegate
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
            title = [_delegate performanceAnalyzer:self titleMethodWithViewController:viewController];
        }
    } while (0);
    Class cls = [viewController class];
    __block BOOL exists = NO;
    [_registeredObservereds enumerateObjectsUsingBlock:^(CHObserveredPrivate *obj, NSUInteger idx, BOOL *stop) {
        if ([cls isSubclassOfClass:obj.observered.class] && obj.active) {
            *stop = YES;
            exists = YES;
        }
    }];
    if (exists) {
        return;
    }
    [self updatePageLoadingWithClassName:NSStringFromClass(cls)
                     andUpdateModuleName:title];
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
    CHPerformanceDataPackager *packager = [CHPerformanceDataPackager packagerWithPerformanceShowType:_performanceWindow.showType];
    packager.dataSource = _performanceData;
    NSString *text = [packager performanceDataLocalizedToCSV];
    NSError *error = nil;
    NSString *fullpath = [PerformanceDataFilePath() stringByAppendingPathComponent:@"performance.txt"];
    [text writeToFile:fullpath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [msg appendString:@"(save Failed!)"];
    } else {
        [msg appendString:@"(save OK!)"];
        fullpath = nil;
    }
    if (_analyzerFlags.methodFlagPerformanceAnalyzerCompleteWithFilePath) {
        [_delegate performanceAnalyzer:self completeWithFilePath:fullpath];
    }
    _performanceWindow.moduleTitleString = msg;
}

@end


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
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    invocation.selector = @selector(application_aop:didFinishLaunchingWithOptions:);
#pragma clang diagnostic pop
    void *app = (__bridge void *)application;
    [invocation setArgument:&app atIndex:2];

    void *l = (__bridge void *)launchOptions;
    [invocation setArgument:&l atIndex:3];
    [invocation invoke];
    BOOL t = 0;
    [invocation getReturnValue:&t];
    if (CHPerformanceAnalyzerAOPInitializer) {
        CHPerformanceAnalyzerAOPInitializer();
    }
    [[CHPerformanceAnalyzer sharedPerformanceAnalyzer] startAnalysis];
    return t;
}

#if defined(__cplusplus)
}
#endif