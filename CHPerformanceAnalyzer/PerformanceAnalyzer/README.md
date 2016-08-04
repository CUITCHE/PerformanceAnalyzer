> Static library help you quikly integrate. Avoid Xcode version differences that may not compile successfully.

# Use
- Copy [directory](./libPerformanceAnalyzer/) to your project
- At `Build Settings` -- `Other Linker Flags`, set it to `-ObjC` (You can search Other Linker Flags)
- Include file `CHPerformanceAnalyzer.h` in **`main.mm`**（Carefully! Its main.mm）, and invoke C method `startPerformanceAnalyzer()` in main method.

----------
> 静态库可以帮你快速集成，并且避免了因为Xcode的版本差异导致编译不成功。

# 使用
- 添加[directory](./libPerformanceAnalyzer/)到你的项目
- 在`Build Settings` -- `Other Linker Flags`中设置编译选项`-ObjC`（你可以直接搜索，便于定位）
- 在**`main.mm`**文件中包含`CHPerformanceAnalyzer.h`文件，在main函数中调用`startPerformanceAnalyzer()`方法