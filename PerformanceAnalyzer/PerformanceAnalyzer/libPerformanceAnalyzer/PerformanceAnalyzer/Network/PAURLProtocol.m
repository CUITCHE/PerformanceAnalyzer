//
//  PAURLProtocol.m
//  libPerformanceAnalyzer
//
//  Created by hejunqiu on 2018/6/9.
//  Copyright © 2018 hejunqiu. All rights reserved.
//

#import "PAURLProtocol.h"

static NSString *const DMHTTP = @"LPDHTTP";
NSString *const PAURLProtocolNetworkTaskKey = @"task";
NSString *const PAURLProtocolStardDateKey = @"date.start";
NSString *const PAURLProtocolEndDateKey = @"date.end";
NSString *const PAURLProtocolErrorKey = @"error";

void(^networkInterceptorComplete)(NSDictionary<NSString *, id> *completeArguments) = nil;
void(^networkInterceptorWillStart)(NSURLRequest *request) = nil;

@interface PAURLProtocol () < NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOperationQueue     *sessionDelegateQueue;
@property (nonatomic, strong) NSDate               *startDate;
@property (nonatomic, strong) NSError              *error;

@end

@implementation PAURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"]) {
        return NO;
    }
    if ([NSURLProtocol propertyForKey:DMHTTP inRequest:request] ) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:DMHTTP
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

- (void)startLoading {
    self.startDate                                        = [NSDate date];
    NSURLSessionConfiguration *configuration              = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.sessionDelegateQueue                             = [[NSOperationQueue alloc] init];
    self.sessionDelegateQueue.maxConcurrentOperationCount = 1;
    self.sessionDelegateQueue.name                        = @"com.performanceanalyzer.queque.urlprotocol";
    NSURLSession *session                                 = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:self.sessionDelegateQueue];
    self.dataTask                                         = [session dataTaskWithRequest:self.request];
    if (networkInterceptorWillStart) {
        networkInterceptorWillStart(self.request);
    }
    [self.dataTask resume];
}

- (void)stopLoading {
    [self.dataTask cancel];

    if (networkInterceptorComplete != nil) {
        NSMutableDictionary<NSString *, id> *arguments = @{PAURLProtocolNetworkTaskKey: self.dataTask,
                                                           PAURLProtocolStardDateKey: self.startDate,
                                                           PAURLProtocolEndDateKey: [NSDate date]
                                                           }.mutableCopy;
        if (self.error) {
            arguments[PAURLProtocolErrorKey] = self.error;
        }
        networkInterceptorComplete(arguments);
    }
    self.dataTask = nil;
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else {
        self.error = error;
        [self.client URLProtocol:self didFailWithError:error];
    }
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
//    [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
//}

@end
