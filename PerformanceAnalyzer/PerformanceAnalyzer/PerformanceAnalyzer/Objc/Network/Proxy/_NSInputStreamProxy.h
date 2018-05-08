//
//  _NSInputStreamProxy.h
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/4/10.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _NSInputStreamProxy : NSProxy {
    NSInputStream *stream;
}

+ (instancetype)inputStreamWithStream:(id)stream;

@end
