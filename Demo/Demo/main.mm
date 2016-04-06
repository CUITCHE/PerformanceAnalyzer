//
//  main.m
//  Demo
//
//  Created by hejunqiu on 16/4/6.
//  Copyright © 2016年 che. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

extern void startPerformanceAnalyzer();

int main(int argc, char * argv[]) {
    @autoreleasepool {
        startPerformanceAnalyzer();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
