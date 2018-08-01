//
//  FTBaiduNews.m
//  NewsFetcher
//
//  Created by wilsonhan on 2018/7/17.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTBDNewsData.h"
#import <objc/runtime.h>

static void encodeWithCoder(id data, NSCoder *aCoder)
{
    unsigned int count;
    Ivar *ivars = class_copyIvarList([data class], &count);
    for(int i = 0; i < count; i++) {
        Ivar iv = ivars[i];
        const char *name = ivar_getName(iv);
        NSString *strName = [NSString stringWithUTF8String:name];
        id value = [data valueForKey:strName];
        [aCoder encodeObject:value forKey:strName];
    }
    free(ivars);
}

static void initWithCoder(id data, NSCoder *aDecoder)
{
    unsigned int count;
    Ivar *ivars = class_copyIvarList([data class], &count);
    for(int i = 0; i < count; i++) {
        Ivar iv = ivars[i];
        const char *name = ivar_getName(iv);
        NSString *strName = [NSString stringWithUTF8String:name];
        id value = [aDecoder decodeObjectForKey:strName];
        [data setValue:value forKey:strName];
    }
    free(ivars);
}

@implementation FTBDNewsData

- (NSString *)description
{
    return [NSString stringWithFormat:@"posterScreenName:%@, url:%@, publishDate:%@, title:%@, imageUrls:%@, newsId:%@", self.posterScreenName, self.url, self.publishDate, self.title, self.imageUrls, self.newsId];
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    encodeWithCoder(self, aCoder);
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        initWithCoder(self, aDecoder);
    }
    return self;
}

@end


@implementation FTBDNews

- (NSString *)description
{
    return [NSString stringWithFormat:@"keyword:%@, retcode:%@, data:%@", self.keyword, self.retcode, self.data];
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    encodeWithCoder(self, aCoder);
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        initWithCoder(self, aDecoder);
    }
    return self;
}

@end
