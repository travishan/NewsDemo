//
//  FTBaiduNews.h
//  NewsFetcher
//
//  Created by wilsonhan on 2018/7/17.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * 新闻数据，存储一条新闻相关的数据
 */
@interface FTBDNewsData : NSObject <NSCoding>

//新闻相关属性
@property (strong, nonatomic) NSString *posterScreenName;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSDate *publishDate;
@property (strong, nonatomic) NSString *timeStr;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray<NSString *> *imageUrls;
@property (strong, nonatomic) NSString *newsId;

//辅助属性
@property (assign, nonatomic) BOOL readed;

@end

/**
 * 新闻数据，存储一次或多次请求的一个关键字对应的新闻
 */
@interface FTBDNews : NSObject <NSCoding>

//自定义参数
//搜索的关键字
@property (strong, nonatomic) NSString *keyword;

//用到的参数
@property (strong, nonatomic) NSString *retcode;
@property (strong, nonatomic) NSArray<FTBDNewsData *> *data;

@end
