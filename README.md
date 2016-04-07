# PerformanceAnalyzer
iOS平台下可对APP的CPU、FPS、Memory、LoadingTime进行内部统计的一款工具，并提供统计数据的输出。
# 前言
有项目需求，所以做了这款性能分析工具。正如简介所说，它可以统计iOS APP的CPU、FPS、Memory、LoadingTime。由于我在工具内部设定的是默认0.5秒统计一次所有数据（FPS除外，它一秒统计一次）故而内存开销可能比较大，所以如果你特别在意内存，建议只统计内存，把其它统计项关掉，至于怎么关掉，可以看看后文的详解。
# 优势
只需要把PerformanceAnalyzer文件夹包含进入你的工程，然后修改一下`main.m`文件少许代码就可以启动性能分析器，你甚至都不用包含任何文件。

# 如何使用
- 将我传入的`PerformanceAnalyzer`文件夹复制到你的工程。选择`项目工程`->`Build Phases`->`Link Binary With Libraries`把`libPerformanceAnalyzer.a`添加进去。
- 你不需要包含`CHPerformanceAnalyzer.h`。
- 把项目的`main.m`改成`main.mm`，在main函数中调用`startPerformanceAnalyzer()`方法。可以参考下面的代码，你需要前置声明`extern void startPerformanceAnalyzer()`，因为这个方法存在于性能分析器静态库中，它的作用就是启动性能分析，这个函数将不会做任何多余的工作，它其实就是一个空函数，仅仅是为了把libPerformanceAnalyzer.a中的符号导入到你的工程中。

    ```Objective-C
    extern void startPerformanceAnalyzer();

    int main(int argc, char * argv[]) {
        @autoreleasepool {
            startPerformanceAnalyzer();
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
    }
    ```
- 请运行工程，尽情使用吧！

# 扩展使用
## 自定义数据统计项
你可以在全局的任何地方定义`CHPerformanceAnalyzerShowType CHPerformanceAnalyzerShowTypeSetting;`来控制统计项，它的值请看[CHPerformanceAnalyzer.h](./PerformanceAnalyzer/include/CHPerformanceAnalyzer.h)中的定义。

## 自定义的AppDelegate
一般来说，你的app delegate（遵从UIApplicationDelegate协议的类）是AppDelegate，如果不是怎么办呢，你只需要在全局的任何地方定义`NSString *CHPerformanceAnalyzerApplicationDelegateClassName = @"YourAppDelegate";`即可。

> 在我上传的`PerformanceAnalyzer`文件夹下有`CHPerformancerExterns.m`，你可以在这里面完成上面的操作，默认地，这里面已经有一些内容了，你可以做适当修改。

## 如何获得统计数据
- 当你用两根手指连续点击统计界面2次就会将当前的统计数据保存到沙盒。
- CHPerformanceAnalyzer有一个delegate，它遵从CHPerformanceAnalyzerDelegate协议，这个协议有个可选方法`- (void)performanceAnalysis: completeWithFilePath:;`，每当你触发了保存操作后，它就会被调用。它会告诉你数据保存的位置。
- analyzer把统计数据保存在了沙盒的共享目录下，你可以给工程的ingo.plist添加'Application supports iTunes file sharing'字段，并设置为`YES`，你就可以把手机连上iTunes，在`应用`界面，向下滑到'文件共享'拦，选择你的APP，就会看下图：
[](./res/1.png)
`performance.txt`就是统计数据了。
- 统计数据的格式是Excel的csv格式可以直接导入Excel的，具体教程请看[这里](http://jingyan.baidu.com/article/e6c8503c2d44e3e54f1a18c7.html)。analyzer的默认的数据分隔符是英文逗号，请记得选择。转换的时候，可能有编码问题，如果出现这个问题，建议先把原始数据转换成中文编码再导入。

## 自定义设置加载时间的END FLAG
如果有的view controller比较特殊，需要延迟一会儿才能加载完整个界面，而此时`- (void)viewDidAppear:`已经被调用过。此时，需要自己去定制一个方法去表示END FLAG并替换analyzer的END FLAG。你可以查看我在PerformanceAnalyzer里面的[CHPerformancerExterns.mm](./PerformanceAnalyzer/include/CHPerformancerExterns.mm)文件。为了方便解释，这里贴出代码：

```Objective-C
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
```
我们加载一个网页的时候，当调用了协议方法`- (void)webViewDidFinishLoad:`后，就代表网页加载完毕了，我在这个方法中更改了navigation的标题。
`[analyzer addObservered:self forKeyPath:@"navigationItem.title"];`的作用就是让analyzer作为Controller的观察者，观察Controller的`navigationItem.title`属性路径，发生了新值变化后，analyzer就会收到对应通知，此时analyzer就会更新页面的加载时间。你也可以关注其它属性路径，我这儿只是抛砖引玉。

其中`[self viewDidAppear_aop2:animated];`和在`CHPerformanceAnalyzerAOPInitializer`block中的
```
[analyzer registerLoadingRuleWithClass:[WebViewController class]
                            originalSelector:@selector(viewDidAppear:)
                                        newSEL:@selector(viewDidAppear_aop2:)];
```
这两句的代码以及顺序不能颠倒，这两句采用了AOP技术，更新内部实现。

注意：不能使用`viewDidAppear_aop`作为你的自定义函数名字，analyzer内部采用了这个名字，如果不幸，你这样使用，将会进入无限递归直至爆栈。

## 跳过特定的模块
你可以设置analyzer的skipModules属性的值，来跳过一些模块的统计。

## 关闭统计
摇晃手机就可以关闭anayzer，再次摇晃就会开启。

# 注意
- Module的名字来自navigationItem的title属性，请设置它的属性，如果没有CHPerformanceAnalyzer就会从它的titleView中查找，如果没有就会为null。
- 每个View Controller的加载时间是从调用`- (void)loadView`前开始，直到调用完`- (void)viewDidAppear:`