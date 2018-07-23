//
//  FTBDNewsDataManager.h
//  BaiduIn100Companies
//
//  Created by wilsonhan on 2018/7/17.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FTBDNews;
@class FTBDNewsData;


@protocol FTBDNewsDelegate <NSObject>

@required
- (void)notifyData:(NSArray *)news keyword:(NSString *)keyword;

@optional
- (void)notifyImageDownload:(NSInteger)cellId;

@end


@interface FTBDNewsDataManager : NSObject

@property (nonatomic, weak) id<FTBDNewsDelegate> delegate;

//@property (nonatomic, strong) NSArray *filterNewsData;

/**
 * 解析拉取的新闻数据
 */
+ (FTBDNews *)analysisNews:(NSString *)keyword data:(NSData *)data;

/**
 * 启动新闻数据拉取
 */
- (void)pullBaiduNews:(NSString *)keyword date:(NSDate *)date;

/**
 * 获取缓存的新闻数据
 */
- (void)getBaiduNews:(NSString *)keyword date:(NSDate *)date;

/**
 * 加载新闻对应的图片
 */
- (void)pullNewsImage:(FTBDNewsData *)newsData cellId:(NSInteger)cellId;

/**
 * 根据日期过滤新闻，通过回调函数更新
 */
- (void)requireNews:(NSString *)keyword date:(NSDate *)date;

/**
 * 获取图片
 */
- (UIImage *)imageForId:(NSString *)newsId;

/**
 * 通过keyword获取新闻data
 */
- (FTBDNewsData *)getNewsDataFromKeyword:(NSString *)kw index:(NSUInteger)index;




//test
- (void)testImageDownload;



+ (FTBDNewsDataManager *)sharedInstance;

@end
