//
//  CHPerformanceAnalyzerWindow.m
//  CHPerformanceAnalyzer
//
//  Created by hejunqiu on 16/7/18.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import "CHPerformanceAnalyzerWindow.h"
#import "CHAOPManager.h"
#import "CHMetaMacro.h"
#import "PureLayout.h"

struct _InternalMethodFlags {
    uint32_t methodFlagViewControllerLoadingView    : 1;
    uint32_t methodFlagViewControllerDidApper       : 1;
    uint32_t methodFlagPerformanceAnalyzerWantStart : 1;
    uint32_t methodFlagPerformanceAnalyzerWantStop  : 1;
    uint32_t methodFlagPerformanceAnalyzerWantSave  : 1;
};

extern __weak CHPerformanceAnalyzerWindow *instanceButInternal;

@interface CHPerformanceAnalyzerWindow ()
{
    UILabel* _defaultViews[CHInternalIndexCount];
}

@property (nonatomic) CHPerformanceAnalyzerShowType showType;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, weak) NSLayoutConstraint *topConstraint;
@property (nonatomic, weak) NSLayoutConstraint *leftConstraint;

@property (nonatomic) struct _InternalMethodFlags analyzerFlags;
@property (nonatomic, strong) NSMutableSet<Class> *skipClass;

@end

@implementation CHPerformanceAnalyzerWindow

- (instancetype)initWithAnalyzerType:(CHPerformanceAnalyzerShowType)type frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.windowLevel = UIWindowLevelStatusBar + (1 << 5);
        _showType = type;
        [self createDefaultViews];
        [self setupLayouts];
        [self initializGestures];
        [self.class methodExchange];
        _skipClass = [NSMutableSet setWithArray:@[NSClassFromString(@"UIInputWindowController"), [UINavigationController class]]];
        [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    }
    return self;
}

#pragma mark - initializer
- (void)createDefaultViews
{
    @weakify(self);
    UILabel* (^block)(NSString *, int) = ^UILabel *(NSString *title, int position) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        label.text = title;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        @strongify(self);
        [self addSubview:label];
        self->_defaultViews[position] = label;
        return label;
    };
    block(@"Module", CHInternalIndexModule);
    block(@"CPU", CHInternalIndexCPU);
    block(@"Memory", CHInternalIndexMemory);
    block(@"Pageloading", CHInternalIndexPageLoading);
    block(@"FPS", CHInternalIndexFPS);
    if (!option_check(_showType, CHPerformanceAnalyzerShowTypeCPU)) {
        _defaultViews[CHInternalIndexCPU].hidden = YES;
    }
    if (!option_check(_showType, CHPerformanceAnalyzerShowTypeMemory)) {
        _defaultViews[CHInternalIndexMemory].hidden = YES;
    }
    if (!option_check(_showType, CHPerformanceAnalyzerShowTypePageLoading)) {
        _defaultViews[CHInternalIndexPageLoading].hidden = YES;
    }
    if (!option_check(_showType, CHPerformanceAnalyzerShowTypeFPS)) {
        _defaultViews[CHInternalIndexFPS].hidden = YES;
    }
}

- (void)setupLayouts
{
    UILabel *module = _defaultViews[CHInternalIndexModule];
    _topConstraint = [module autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5-64];
    _leftConstraint = [module autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [module autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];

    NSArray<__kindof UIView *> *views = @[_defaultViews[CHInternalIndexCPU],
                                          _defaultViews[CHInternalIndexMemory],
                                          _defaultViews[CHInternalIndexPageLoading],
                                          _defaultViews[CHInternalIndexFPS]];
    UIView *lastView = module;
    for (UIView *view in views) {
        [view autoAlignAxis:ALAxisVertical toSameAxisOfView:module];
        [view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView];
        [view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
        lastView = view;
    }
}

- (void)initializGestures
{
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(panGestureHandler:)];
    [self addGestureRecognizer:_panGestureRecognizer];

    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(tapGestureHandler:)];
    _tapGestureRecognizer.numberOfTapsRequired = 2;
    _tapGestureRecognizer.numberOfTouchesRequired = 2;
    [self addGestureRecognizer:_tapGestureRecognizer];
}

+ (void)methodExchange
{
    Class cls = [UIViewController class];
    [CHAOPManager aopInstanceMethodWithOriClass:cls
                                         oriSEL:@selector(loadView)
                                       aopClass:cls
                                         aopSEL:@selector(loadView_aop)];

    [CHAOPManager aopInstanceMethodWithOriClass:cls
                                         oriSEL:@selector(viewDidAppear:)
                                       aopClass:cls
                                         aopSEL:@selector(viewDidAppear_aop:)];
}

#pragma mark - Gestures
- (void)panGestureHandler:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _startPoint = [gesture locationInView:self];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [gesture locationInView:self];
        CGFloat x = location.x - _startPoint.x;
        CGFloat y = location.y - _startPoint.y;
        CGRect frame = CGRectOffset(self.frame, x, y);
        self.frame = frame;
        _topConstraint.constant -= y;
        _leftConstraint.constant -= x;
        [self setNeedsUpdateConstraints];
    }
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (_analyzerFlags.methodFlagPerformanceAnalyzerWantSave) {
            [_delegate performanceAnalyzerWantSave:self];
        }
    }
}

#pragma mark - Shake
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
        if (self.hidden) {
            if (_analyzerFlags.methodFlagPerformanceAnalyzerWantStart) {
                [_delegate performanceAnalyzerWantStart:self];
            }
        } else {
            if (_analyzerFlags.methodFlagPerformanceAnalyzerWantStop) {
                [_delegate performanceAnalyzerWantStop:self];
            }
        }
    }
}

#pragma mark - property
- (void)setDelegate:(id<CHPerformanceAnalyzerWindowDelegate>)delegate
{
    if (![_delegate isEqual:delegate]) {
        _delegate = delegate;
        _analyzerFlags.methodFlagViewControllerLoadingView = [_delegate respondsToSelector:@selector(viewControllerLoadingView:)];
        _analyzerFlags.methodFlagViewControllerDidApper = [_delegate respondsToSelector:@selector(viewControllerDidApper:)];
        _analyzerFlags.methodFlagPerformanceAnalyzerWantStart = [_delegate respondsToSelector:@selector(performanceAnalyzerWantStart:)];
        _analyzerFlags.methodFlagPerformanceAnalyzerWantStop = [_delegate respondsToSelector:@selector(performanceAnalyzerWantStop:)];
        _analyzerFlags.methodFlagPerformanceAnalyzerWantSave = [_delegate respondsToSelector:@selector(performanceAnalyzerWantSave:)];
    }
}

- (void)setModuleTitleString:(NSString *)moduleTitleString
{
    if (![_defaultViews[CHInternalIndexModule].text isEqualToString:moduleTitleString]) {
        _defaultViews[CHInternalIndexModule].text = [NSString stringWithFormat:@"Moudel:%@", moduleTitleString];
    }
}

- (NSString *)moduleTitleString
{
    return _defaultViews[CHInternalIndexModule].text;
}

#pragma mark - public
- (void)setPageLoadingTimeWithValue:(NSTimeInterval)interval
{
    NSString *text = nil;
    if (interval >= 0) {
        text = [NSString stringWithFormat:@"Page Loading:%.04fs", interval];
    } else {
        text = @"Page Loading:Pop out";
    }
    _defaultViews[CHInternalIndexPageLoading].text = text;
}

- (void)setMemoryWithValue:(CGFloat)usage
{
    NSString *str = nil;
    if (usage >= 0) {
        str = [NSString stringWithFormat:@"Memory:%.02fMB", usage];
    } else {
        str = @"Memory:Recorded";
    }
    _defaultViews[CHInternalIndexMemory].text = str;
}

- (void)setCPUWithValue:(CGFloat)cpuRate
{
    _defaultViews[CHInternalIndexCPU].text = [NSString stringWithFormat:@"CPU:%.02f%%", cpuRate];
}

- (void)setFPSWithValue:(CGFloat)fps
{
    _defaultViews[CHInternalIndexFPS].text = [NSString stringWithFormat:@"FPS:%.01f", fps];
}

- (void)addSkipModuleWithClassName:(Class)aClass
{
    [_skipClass addObject:aClass];
}
@end


#pragma mark - UIViewController Category (PageLoading)
@implementation UIViewController (PageLoading)

- (void)loadView_aop
{
    @onExit {
        [self loadView_aop];
    };
    do {
        if (!instanceButInternal.analyzerFlags.methodFlagViewControllerLoadingView) {
            break;
        }
        NSSet *set = instanceButInternal.skipClass;
        for (Class aClass in set) {
            if ([self isMemberOfClass:aClass]) {
                goto ext;
            }
        }
        [instanceButInternal.delegate viewControllerLoadingView:self];
    } while (0);
ext:;
}

- (void)viewDidAppear_aop:(BOOL)animated
{
    [self viewDidAppear_aop:animated];
    do {
        if (!instanceButInternal.analyzerFlags.methodFlagViewControllerDidApper) {
            break;
        }
        NSSet *set = instanceButInternal.skipClass;
        for (Class aClass in set) {
            if ([self isMemberOfClass:aClass]) {
                goto ext;
            }
        }
        [instanceButInternal.delegate viewControllerDidApper:self];
    } while (0);
ext:;
}

@end