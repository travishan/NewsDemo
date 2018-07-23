//
//  FTNewsFetcher.h
//  NewsFetcher
//
//  Created by wilsonhan on 2018/7/17.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FTBDNews;
@class FTBDNewsData;

typedef void (^FTBDNewsFetcherBlock)(NSString *keyword, NSData *data);
typedef void (^FTBDImageDownloadBlock)(NSData *data);

/**
 * 新闻抓取类，提供新闻抓取方法
 */
@interface FTBDNewsFetcher : NSObject

/**
 * 请求下载新闻数据
 */
- (void)requestBDNews:(NSString *)keyword block:(FTBDNewsFetcherBlock)block;

/**
 * 请求下载图片
 */
- (void)requestBDNewsImage:(NSString *)url block:(FTBDImageDownloadBlock)block;

//测试方法
+ (NSString *)testURL:(NSString *)kw;
+ (void)testRequest:(FTBDNewsFetcherBlock)block;

@end
