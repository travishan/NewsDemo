//
//  FTBDNewsDataManager.m
//  BaiduIn100Companies
//
//  Created by wilsonhan on 2018/7/17.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTBDNewsDataManager.h"
#import "FTBDNewsFetcher.h"
#import "FTBDNewsData.h"
#import "FTCalendarHelper.h"


@interface FTBDNewsDataManager ()
{
    FTBDNewsFetcher *_fetcher;
}

@property (nonatomic, strong) NSMutableDictionary<NSString *, FTBDNews *> *newsDict;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *imageDict;

@end

@implementation FTBDNewsDataManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        _fetcher = [[FTBDNewsFetcher alloc] init];
        _newsDict = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return self;
}

#pragma mark - Pull News

- (void)pullBaiduNews:(NSString *)keyword date:(NSDate *)date
{
    [_fetcher requestBDNews:keyword block:^(NSString *keyword, NSData *data) {
        //获取数据，存储到字典中
        FTBDNews *res = [FTBDNewsDataManager analysisNews:keyword data:data];
        if(res == nil) {
            NSLog(@"pullBaiduNews-->Fetcher:requestBDNews，数据解析为空。");
            return;
        }
        [self.newsDict setObject:res forKey:keyword];
        __weak FTBDNewsDataManager *weakSelf = self;
        if(date == nil) {
            [weakSelf notifyToDelegate:res.data];
        } else {
            [weakSelf requireNews:keyword date:date];
        }
        
    }];
}

- (void)pullNewsImage:(FTBDNewsData *)newsData cellId:(NSInteger)cellId
{
    UIImage *image = [_imageDict objectForKey:newsData.newsId];
    if(image == nil) {
        if(newsData.imageUrls == nil || [newsData.imageUrls isEqual:[NSNull null]]) {
            return;
        }
        NSString *url = [newsData.imageUrls firstObject];
        if(url == nil) {
            return;
        }
        __weak FTBDNewsDataManager *_weakSelf = self;
        FTBDImageDownloadBlock blk = ^(NSData *data) {
            UIImage *im = [UIImage imageWithData:data];
            NSLog(@"data.length = %ld", data.length);
            [_weakSelf.imageDict setObject:im forKey:newsData.newsId];
            if([_weakSelf.delegate respondsToSelector:@selector(notifyImageDownload:)]) {
                [_weakSelf.delegate notifyImageDownload:cellId];
            }
        };
        [_fetcher requestBDNewsImage:url block:blk];
    }
}

//根据传入的日期过滤出新闻
- (void)requireNews:(NSString *)keyword date:(NSDate *)date
{
    if(date == nil) {
        [self nofityWithAllData:keyword];
        return;
    }
    FTBDNews *news = [self.newsDict objectForKey:keyword];
    if(news != nil) {
        __weak FTBDNewsDataManager *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:news.data.count];
            for(FTBDNewsData *data in news.data) {
                if([FTCalendarHelper isSameDay:data.publishDate date2:date]) {
                    [arr addObject:data];
                }
            }
            [weakSelf notifyToDelegate:arr];
        });
        
    }
}

#pragma mark - private

- (void)notifyToDelegate:(NSArray *)dataArr
{
    if([self.delegate respondsToSelector:@selector(notifyData:)]) {
        [self.delegate notifyData:dataArr];
    }
}

- (void)nofityWithAllData:(NSString *)keyword
{
    FTBDNews *res = [_newsDict objectForKey:keyword];
    if(res == nil) {
        NSLog(@"从Manager中获取数据失败，keyword：%@", keyword);
        return;
    }
    [self notifyToDelegate:res.data];
}

#pragma mark - Class Method

+ (FTBDNews *)analysisNews:(NSString *)keyword data:(NSData *)data
{
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
    if(dic == nil) {
        NSLog(@"JSON data解析出错, %@", err.localizedDescription);
    }
    return [FTBDNewsDataManager newsMaker:dic];
}

+ (FTBDNews *)newsMaker:(NSDictionary *)dic
{
    if(dic == nil) {
        return nil;
    }
    //data formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:MM:ss"];
    //analysis json dictionary
    FTBDNews *res = [[FTBDNews alloc] init];
    res.retcode = dic[@"retcode"];
    NSArray *rawDataArr = dic[@"data"];
    NSMutableArray<FTBDNewsData *> *newsDataArr = [NSMutableArray arrayWithCapacity:rawDataArr.count];
    res.data = newsDataArr;
    for(NSDictionary *data in rawDataArr) {
        FTBDNewsData *newsData = [[FTBDNewsData alloc] init];
        newsData.posterScreenName = data[@"posterScreenName"];
        newsData.url = data[@"url"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[data[@"publishDate"] doubleValue]];
        newsData.publishDate = date;
        newsData.timeStr = [formatter stringFromDate:date];
        newsData.title = data[@"title"];
        newsData.imageUrls = data[@"imageUrls"];
        newsData.newsId = data[@"id"];
        
        [newsDataArr addObject:newsData];
    }
    
    return res;
}

#pragma mark - getter/setter

- (UIImage *)imageForId:(NSString *)newsId
{
    return [self.imageDict objectForKey:newsId];
}

- (FTBDNewsData *)getNewsDataFromKeyword:(NSString *)kw index:(NSUInteger *)index
{
    FTBDNews *news = [_newsDict objectForKey:kw];
    if(news == nil || news.data == nil || news.data.count == 0) {
        return nil;
    }
    FTBDNewsData *res = [news.data objectAtIndex:index];
    return res;
}

#pragma mark - Singleton

static FTBDNewsDataManager *instance = nil;

+ (FTBDNewsDataManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(instance == nil) {
            instance = [[FTBDNewsDataManager alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(instance == nil) {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

- (id)copy
{
    return self;
}


- (void)testImageDownload
{
    
    FTBDImageDownloadBlock blk = ^(NSData *data) {
        
        UIImage *im = [UIImage imageWithData:data];
        NSLog(@"data.length = %ld", data.length);
        
        
    };
    NSString *url1 = @"http://t11.baidu.com/it/u=3727519330,2502932454&fm=82&s=A63151838E32359C5D59D50F03&w=121&h=81&img.JPEG";
    NSString *url2 = @"http://t11.baidu.com/it/u=796633171,3249965741&fm=55&app=22&f=JPEG?w=121&h=81&s=E9B874D8F230CE7558C965080300E0D2";
    NSString *url0 = @"https://ss1.baidu.com/6ONXsjip0QIZ8tyhnq/it/u=2058261181,699888508&fm=173&app=25&f=JPEG?w=640&h=511&s=E4F835C7E1DE8FDA0C60A02A03002093";
    NSString *url3 = @"http://file.ituring.com.cn/SmallCover/1707879dce8408ff6542";
    [_fetcher requestBDNewsImage:url1 block:blk];
}

@end
