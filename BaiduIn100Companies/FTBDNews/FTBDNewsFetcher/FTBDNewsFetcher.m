//
//  FTNewsFetcher.m
//  NewsFetcher
//
//  Created by wilsonhan on 2018/7/17.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTBDNewsFetcher.h"
#import "FTBDNewsData.h"

static NSString *FTBDNewsURL = @"https://120.76.205.241/news/baidu?apikey=qI9UW0gCBOdRSyUVjLo1tyHDZe4rwjHYs0tngCXcGQpkc6hT9X7usZq0tTYhUtDn&page=4";

static NSString *FTBDNewsURLParametersKeyword = @"&kw=";

//static const float FTBaiduNewsRequestOuttime = 10.0;

//#define FTURLMaker(keyword) [NSString stringWithFormat:@"%@%@%@", FTBaiduNewsURL, FTBaiduNewsURLParametersKeyword, keyword];

inline
static NSString *FTBDNewsURLMaker(NSString *keyword)
{
    return [NSString stringWithFormat:@"%@%@%@", FTBDNewsURL, FTBDNewsURLParametersKeyword, keyword];
}


@interface FTBDNewsFetcher () <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
{
    NSArray<NSURL *> *_urlList;
    NSArray<FTBDNewsFetcherBlock> *_blockList;
    
    NSURLSession *_session;
    
    NSMutableData *mainData;
    FTBDImageDownloadBlock block;
}

@end


@implementation FTBDNewsFetcher


#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _urlList = [NSMutableArray arrayWithCapacity:5];
        _blockList = [NSMutableArray arrayWithCapacity:5];
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    }
    return self;
}


#pragma mark - Download

- (void)requestBDNews:(NSString *)keyword block:(FTBDNewsFetcherBlock)block
{
    //路径中包含汉字，必须转换字符集
    NSString *path = [FTBDNewsURLMaker(keyword) stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:path];
    
    //https请求
    NSURLSessionDataTask *dataTask = [_session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data == nil) {
            NSLog(@"加载图片时异常，错误原因：data为空");
            return;
        }
        if(error != nil) {
            NSLog(@"加载新闻数据时异常，错误原因：%@", error.localizedDescription);
            return;
        }
        block(keyword, data);
    }];
    
    [dataTask resume];
}

- (void)requestBDNewsImage:(NSString *)_url block:(FTBDImageDownloadBlock)_block
{
    NSString *_urlCharacter = [_url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:_urlCharacter];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setValue:@"never" forHTTPHeaderField:@"referer"];

    NSURLSessionDataTask *dataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(response != nil) {
            NSLog(@"length = %lld, name = %@", response.expectedContentLength, response.suggestedFilename);
        }
        if(data == nil) {
            NSLog(@"加载图片时异常，错误原因：data为空");
            return;
        }
        if(error != nil) {
            NSLog(@"加载图片时异常，错误原因：%@", error.localizedDescription);
        }
        _block(data);
    }];
    block = _block;
    [dataTask resume];
}


#pragma mark NSURLSessionDataDelegate

//处理https CA证书
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    NSLog(@"处理证书");
    NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

//任务收到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    long long expLength = response.expectedContentLength;
    NSLog(@"length = %lld", expLength);
    if(expLength == -1) {
        completionHandler(NSURLSessionResponseCancel);
    } else {
        completionHandler(NSURLSessionResponseAllow);
        mainData = [NSMutableData data];
    }
}

//收到数据的回调方法，多次执行
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [mainData appendData:data];
    NSLog(@"data length = %ld", data.length);
}

#pragma mark - NSURLSessionTaskDelegate

//任务完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [_session finishTasksAndInvalidate];
    block(mainData);
}

#pragma mark - test

+ (NSString *)testURL:(NSString *)kw
{
    NSString *res = FTBDNewsURLMaker(kw);
    return res;
}

+ (void)testRequest:(FTBDNewsFetcherBlock)blk
{
//    FTBDNewsFetcher *f = [FTBDNewsFetcher sharedInstance];
//    [f fetchNews:@"富途" block:blk];
}

@end
