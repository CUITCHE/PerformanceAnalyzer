lipo -create Debug-iphoneos/libPerformanceAnalyzer.a Debug-iphonesimulator/libPerformanceAnalyzer.a -output libPerformanceAnalyzerd.a
lipo -create Release-iphoneos/libPerformanceAnalyzer.a Release-iphonesimulator/libPerformanceAnalyzer.a -output libPerformanceAnalyzer.a
lipo -create libPerformanceAnalyzerd.a libPerformanceAnalyzer.a -output libPerformanceAnalyzer.a
rm libPerformanceAnalyzerd.a
cp libPerformanceAnalyzer.a CHPerformanceAnalyzer/libPerformanceAnalyzer.a