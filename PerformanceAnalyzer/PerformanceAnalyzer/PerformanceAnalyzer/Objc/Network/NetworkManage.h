//
//  NetwokManage.h
//  PerformanceAnalyzer
//
//  Created by He,Junqiu on 2018/4/11.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

class NetworkManage {
    struct NetworkManagePrivate *data;
    NetworkManage();
public:

    static NetworkManage& standard();

    ~NetworkManage();

    void setDelegate(id delegate);

    void append(NSURLConnection *c);

    void startedRequest(NSURLConnection *c);
    void sentBytes(NSURLConnection *c, NSInteger bytes);
    void endedRequest(NSURLConnection *c);

    void receivedResponse(NSURLConnection *c);
    void receivedBytes(NSURLConnection *c, NSInteger bytes);

    void finallyFinishing(NSURLConnection *c);

    void endWithError(NSURLConnection *c, NSError *error);
};
