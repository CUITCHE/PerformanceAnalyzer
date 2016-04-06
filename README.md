# PerformanceAnalyzer
iOS平台下可对APP的CPU、FPS、Memory、LoadingTime进行内部统计的一款工具，并提供统计数据的输出。
# 前言
有项目需求，所以做了这款性能分析工具。正如简介所说，它可以统计iOS APP的CPU、FPS、Memory、LoadingTime。由于我在工具内部设定的是默认0.5秒统计一次所有数据（FPS除外，它一秒统计一次）故而内存开销可能比较大，所以如果你特别在意内存，建议只统计内存，把其它统计项关掉，至于怎么关掉，可以看看后文的详解。
# 优势
只需要把framework文件夹包含进入你的工程，然后修改一下`main.m`文件少许代码就可以启动性能分析器，你甚至都不用包含任何文件。

# 如何使用
- 将我传入的Demo工程中的framework文件夹复制到你的工程。
- 你不需要包含`CHPerformanceAnalyzer.h`。
- 把项目的`main.m`改成`main.mm`，在main函数中调用`startPerformanceAnalyzer()`方法。可以参考下面的代码，你需要前置声明`extern void startPerformanceAnalyzer()`，因为这个方法存在于性能分析器静态库中，它的作用就是启动性能分析。

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
你可以在全局的任何地方定义`CHPerformanceAnalyzerShowType CHPerformanceAnalyzerShowTypeSetting;`来控制统计项，它的值请看[CHPerformanceAnalyzer.h](./Demo/Demo/framework/CHPerformanceAnalyzer.h)中的定义。

## 自定义的AppDelegate
一般来说，你的app delegate（遵从UIApplicationDelegate协议的类）是AppDelegate，如果不是怎么办呢，你只需要在全局的任何地方定义`NSString *CHPerformanceAnalyzerApplicationDelegateClassName = @"YourAppDelegate";`即可。

## 如何获得统计数据
- 当你用两根手指连续点击统计界面2次就会将当前的统计数据保存到沙盒。
- CHPerformanceAnalyzer有一个delegate，它遵从CHPerformanceAnalyzerDelegate协议，这个协议有个可选方法`- (void)performanceAnalysis: completeWithFilePath:;`，每当你触发了保存操作后，它就会被调用。它会告诉你数据保存的位置。

# 注意
- Module的名字来自navigationItem的title属性，请设置它的属性，如果没有CHPerformanceAnalyzer就会从它的titleView中查找，如果没有就会为null。
- 每个View Controller的加载时间是从调用`- (void)loadView`前开始，直到调用完`- (void)viewDidAppear:`
- 若想要统计webview的加载时间，请等待我的下一次README.md更新，通过CHPerformanceAnalyzer是可以实现的。只不过我现在没时间写下，有想法的读者，可以自己尝试写写。