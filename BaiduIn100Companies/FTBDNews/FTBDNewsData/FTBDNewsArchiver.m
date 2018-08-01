//
//  FTBDNewsArchiver.m
//  BaiduIn100Companies
//
//  Created by wilsonhan on 2018/7/23.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTBDNewsArchiver.h"
#import "FTBDNewsData.h"

static NSString * const sFTBDNewsKeywordFileName = @"FTBDNewsKeywordList";

@implementation FTBDNewsArchiver

//在data manager中数据存储方式为dictionary，每一个keyword对应一个FTBDNews
//图片单独保存为一个dictionary，每一个keyword对应
//存储方案为
//1. 使用直接写的方式将所有keyword以NSArray形式写入NSUserDefaults
//2. 使用NSKeyedArchiver方式将每一个keyword对应的FTBDNews写入一个文件，文件名为keyword
//3. 存储图片，方案待定
//读取方案为
//1. 首先读取NSUserDefaults存储的keyword列表
//2. 根据keyword列表，使用NSKeyedArchiver方式将每一个keyword对应的数据读取到本地
//3. 读取图片，方案待定

- (BOOL)saveNews:(NSDictionary<NSString *, FTBDNews *> *)newsDict
           image:(NSDictionary<NSString *, UIImage *> *)imageDict
{
    NSArray *allKeys = [newsDict allKeys];
    if (allKeys == nil || allKeys.count == 0) {
        NSLog(@"FTBDNewsArchiver->saveNews->keywords列表为空, %@", allKeys);
        return NO;
    }
    //存储keyword list
    if (![self saveKeywordList:allKeys]) {
        NSLog(@"FTBDNewsArchiver->saveNews->存储keyword列表失败");
        return NO;
    }
    //存储data
    if (![self saveDatas:newsDict]) {
        NSLog(@"FTBDNewsArchiver->saveNews->存储newsDict失败");
        return NO;
    }
    
    return YES;
}

- (BOOL)saveKeywordList:(NSArray *)allKeys
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:allKeys forKey:sFTBDNewsKeywordFileName];
    return [userDefaults synchronize];
}

- (BOOL)saveData:(NSString *)keyword news:(FTBDNews *)news
{
    //读取本地的keyword列表，判断列表中是否有传入的keyword
    NSArray *kwList = [self readKeywordList];
    if (kwList == nil) {
        kwList = [NSArray array];
    }
//    NSLog(@"FTBDNewsArchiver->saveData:news:->kwList:%@", kwList);
    if (![kwList containsObject:keyword]) {
        //没有该keyword，则添加到kwList中
        kwList = [kwList arrayByAddingObject:keyword];
        //重新保存keywordList
        if (![self saveKeywordList:kwList]){
            NSLog(@"FTBDNewsArchiver->saveData:news:->重新写入keyword列表失败，当前正要保存的keyword：%@", keyword);
            return NO;
        }
    }
    //存储keyword对应的news
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:keyword];
    BOOL ret = [NSKeyedArchiver archiveRootObject:news toFile:path];
    if (!ret) {
        NSLog(@"FTBDNewsArchiver->saveData:news:->写入文件失败，key：%@，targetPath：%@", keyword, path);
        return NO;
    }
    return YES;
}

- (BOOL)saveDatas:(NSDictionary *)newsDict
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    for(NSString *key in newsDict) {
        FTBDNews *news = [newsDict objectForKey:key];
        //生成路径
        NSString *targetPath = [docPath stringByAppendingPathComponent:key];
        
        BOOL ret = [NSKeyedArchiver archiveRootObject:news toFile:targetPath];
        if (!ret) {
            NSLog(@"FTBDNewsArchiver->saveDatas->data写入文件失败，key：%@，targetPath：%@", key, targetPath);
        }
    }
    return YES;
}

- (void)readNews:(NSMutableDictionary *)newsDict
{
    NSArray *keywordList = [self readKeywordList];
    if (keywordList == nil) {
        NSLog(@"FTBDNewsArchiver->readNews->keywordlist读取失败");
        return;
    }
    NSLog(@"FTBDNewsArchiver->readNews->本地缓存的keyword：%@", keywordList);
    [self readDatas:keywordList newsDict:newsDict];
}

- (NSArray *)readKeywordList
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *keywordList = (NSArray *)[userDefaults objectForKey:sFTBDNewsKeywordFileName];
    return keywordList;
}

- (NSDictionary *)readDatas:(NSArray *)keywordList newsDict:(NSMutableDictionary *)newsDict
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    for(NSString *key in keywordList) {
        NSString *targetPath = [docPath stringByAppendingPathComponent:key];
        FTBDNews *news = [NSKeyedUnarchiver unarchiveObjectWithFile:targetPath];
        if (news == nil) {
            NSLog(@"FTBDNewsArchiver->readDatas->data文件读取失败，key：%@，targetPath：%@", key, targetPath);
        }
        [newsDict setObject:news forKey:key];
    }
    return newsDict;
}


@end
