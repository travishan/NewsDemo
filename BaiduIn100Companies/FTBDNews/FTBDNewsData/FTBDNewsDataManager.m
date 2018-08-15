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
#import "FTBDNewsArchiver.h"

static const char * const FBBDNewsSerialNotifyQueueName = "FBBDNewsSerialNotifyQueueName";

@interface FTBDNewsDataManager ()


@property (strong, nonatomic) dispatch_queue_t serialNotifyQueue;
@property (strong, nonatomic) FTBDNewsFetcher *fetcher;
@property (strong, nonatomic) FTBDNewsArchiver *archiver;
@property (strong, nonatomic) NSMutableDictionary<NSString *, FTBDNews *> *newsDict;//每一个keyword对应一个图片
@property (strong, nonatomic) NSMutableDictionary<NSString *, UIImage *> *imageDict;//每一个newsId对应一个图片

@end

@implementation FTBDNewsDataManager

+ (void)initialize
{
    if (self == [FTBDNewsDataManager class]) {
        
        [FTBDNewsDataManager sharedInstance];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fetcher = [[FTBDNewsFetcher alloc] init];
        _archiver = [[FTBDNewsArchiver alloc] init];
        _serialNotifyQueue = dispatch_queue_create(FBBDNewsSerialNotifyQueueName, DISPATCH_QUEUE_SERIAL);
        //读取数据
        [self initData];
        
    }
    return self;
}

- (void)initData
{
    _newsDict = [[NSMutableDictionary alloc] initWithCapacity:5];
    _imageDict = [[NSMutableDictionary alloc] initWithCapacity:5];
    __weak typeof(self) weakSelf = self;
    dispatch_async(_serialNotifyQueue, ^{
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.archiver readNews:strongSelf.newsDict];
    });
}

#pragma mark - Pull News

- (void)pullBaiduNews:(NSString *)keyword date:(NSDate *)date
{
//    __weak typeof(self) weakSelf = self;
    typeof(self) strongSelf = self;
    
    [_fetcher requestBDNews:keyword block:^(NSString *keyword, NSData *data) {
//        typeof(weakSelf) strongSelf = weakSelf;
        if(!data) {
            return;
        }
        //获取数据，存储到字典中
        FTBDNews *res = [FTBDNewsDataManager analysisNews:keyword data:data];
        if (!res) {
            NSLog(@"FTBDNewsDataManager->pullBaiduNews: 数据解析为空。");
            return;
        }
        [strongSelf.newsDict setObject:res forKey:keyword];
        //存储数据到本地
        if (![self.archiver saveData:keyword news:res]) {
            NSLog(@"FTBDNewsDataManager->pullBaiduNews:->保存数据到本地失败，keyword：%@", keyword);
        }
        if (!date) {
            [strongSelf notifyToDelegate:res.data keyword:keyword];
        } else {
            [strongSelf requireNews:keyword date:date];
        }
    }];
}

/**
 * 获取缓存的新闻数据
 */
- (void)getBaiduNews:(NSString *)keyword date:(NSDate *)date {
    NSLog(@"FTBDNewsDataManager->getBaiduNews->从缓存获取数据");
    FTBDNews *news = [_newsDict objectForKey:keyword];
    if (news != nil) {
        return;
    }
    if (!date) {
        [self notifyToDelegate:news.data keyword:keyword];
    } else {
        [self requireNews:keyword date:date];
    }
}

- (void)pullNewsImage:(FTBDNewsData *)newsData cellId:(NSInteger)cellId
{
    UIImage *image = [_imageDict objectForKey:newsData.newsId];
    if (!image) {
        if (!newsData.imageUrls || [newsData.imageUrls isEqual:[NSNull null]]) {
            return;
        }
        NSString *url = [newsData.imageUrls firstObject];
        if (!url) {
            return;
        }
        __weak FTBDNewsDataManager *weakSelf = self;
        FTBDImageDownloadBlock blk = ^(NSData *data) {
            UIImage *im = [UIImage imageWithData:data];
            if (!im) {
                return;
            }
            [weakSelf.imageDict setObject:im forKey:newsData.newsId];
            if ([weakSelf.delegate respondsToSelector:@selector(notifyImageDownload:)]) {
                [weakSelf.delegate notifyImageDownload:cellId];
            }
        };
        dispatch_async(_serialNotifyQueue, ^{
            [weakSelf.fetcher requestBDNewsImage:url block:blk];
        });
        
    }
}

//根据传入的日期过滤出新闻
- (void)requireNews:(NSString *)keyword date:(NSDate *)date
{
    if (date == nil) {
        [self nofityWithAllData:keyword];
        return;
    }
    FTBDNews *news = [self.newsDict objectForKey:keyword];
    if (news != nil) {
        __weak FTBDNewsDataManager *weakSelf = self;
        dispatch_async(_serialNotifyQueue, ^{
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:news.data.count];
            for(FTBDNewsData *data in news.data) {
                if ([FTCalendarHelper isSameDay:data.publishDate date2:date]) {
                    [arr addObject:data];
                }
            }
            NSLog(@"FTBDNewsDataManager->requiresNews->block(serialQueue): data count:%ld", arr.count);
            [weakSelf notifyToDelegate:arr keyword:keyword];
        });
        
    }
}

/**
 * 检查本地是否有数据
 */
- (BOOL)checkLocal:(NSString *)keyword
{
    return ([_newsDict objectForKey:keyword] == nil) ? NO : YES;
}

#pragma mark - notify

- (void)notifyToDelegate:(NSArray *)dataArr keyword:(NSString *)kw
{
    __weak FTBDNewsDataManager *weakSelf = self;
    dispatch_async(_serialNotifyQueue, ^{
        if ([weakSelf.delegate respondsToSelector:@selector(notifyData:keyword:)]) {
            NSLog(@"FTBDNewsDataManager->notifyToDelegate: 通知delegate数据更新，data数量: %ld", dataArr.count);
            [weakSelf.delegate notifyData:dataArr keyword:kw];
        }
    });

}

- (void)nofityWithAllData:(NSString *)keyword
{
    FTBDNews *res = [_newsDict objectForKey:keyword];
    if (res == nil) {
        NSLog(@"FTBDNewsDataManager->notifyWithAllData: 字典中没有keyword对应的数据，keyword：%@", keyword);
        return;
    }
    [self notifyToDelegate:res.data keyword:keyword];
}

#pragma mark - Class Method

+ (FTBDNews *)analysisNews:(NSString *)keyword data:(NSData *)data
{
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
    if (dic == nil) {
        NSLog(@"JSON data解析出错, %@", err.localizedDescription);
    }
    return [FTBDNewsDataManager newsMaker:dic];
}

+ (FTBDNews *)newsMaker:(NSDictionary *)dic
{
    if (dic == nil) {
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

- (FTBDNewsData *)getNewsDataFromKeyword:(NSString *)kw index:(NSUInteger)index
{
    FTBDNews *news = [_newsDict objectForKey:kw];
    if (news == nil || news.data == nil || news.data.count == 0) {
        return nil;
    }
    FTBDNewsData *res = [news.data objectAtIndex:index];
    return res;
}

#pragma mark - Singleton

static FTBDNewsDataManager *instance = nil;

+ (FTBDNewsDataManager *)sharedInstance
{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (instance == nil) {
//            instance = [[FTBDNewsDataManager alloc] init];
//        }
//    });
//    return instance;
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
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
