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
@property (nonatomic, strong) NSString *posterScreenName;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDate *publishDate;
@property (nonatomic, strong) NSString *timeStr;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray<NSString *> *imageUrls;
@property (nonatomic, strong) NSString *newsId;

//辅助属性
@property (nonatomic, assign) BOOL readed;

@end

/**
 * 新闻数据，存储一次或多次请求的一个关键字对应的新闻
 */
@interface FTBDNews : NSObject <NSCoding>

//自定义参数
//搜索的关键字
@property (nonatomic, strong) NSString *keyword;

//用到的参数
@property (nonatomic, strong) NSString *retcode;
@property (nonatomic, strong) NSArray<FTBDNewsData *> *data;

@end
