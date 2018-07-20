//
//  FTBaiduNews.m
//  NewsFetcher
//
//  Created by wilsonhan on 2018/7/17.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTBDNewsData.h"


@implementation FTBDNewsData

- (NSString *)description
{
    return [NSString stringWithFormat:@"posterScreenName:%@, url:%@, publishDate:%@, title:%@, imageUrls:%@, newsId:%@", self.posterScreenName, self.url, self.publishDate, self.title, self.imageUrls, self.newsId];
}

@end


@implementation FTBDNews

- (NSString *)description
{
    return [NSString stringWithFormat:@"keyword:%@, retcode:%@, data:%@", self.keyword, self.retcode, self.data];
}

@end
