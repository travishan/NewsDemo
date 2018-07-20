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
@interface FTBDNewsData : NSObject

//用到的参数
@property (nonatomic, strong) NSString *posterScreenName;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDate *publishDate;
@property (nonatomic, strong) NSString *timeStr;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray<NSString *> *imageUrls;
@property (nonatomic, strong) NSString *newsId;

//没有用到的参数
//@property (nonatomic, strong) NSString *posterId;
//@property (nonatomic, strong) NSString *content;
//@property (nonatomic, strong) NSString *tags;
//@property (nonatomic, strong) NSString *publishDateStr;
//@property (nonatomic, strong) NSNumber *commentCount;

@end

/**
 * 新闻数据，存储一次或多次请求的一个关键字对应的新闻
 */
@interface FTBDNews : NSObject

//自定义参数
//搜索的关键字
@property (nonatomic, strong) NSString *keyword;

//用到的参数
@property (nonatomic, strong) NSString *retcode;
@property (nonatomic, strong) NSArray<FTBDNewsData *> *data;

//没用到的参数
//@property (nonatomic, assign) BOOL hasNext;
//@property (nonatomic, strong) NSString *appCode;
//@property (nonatomic, strong) NSString *dateType;
//@property (nonatomic, strong) NSString *pageToken;

@end
