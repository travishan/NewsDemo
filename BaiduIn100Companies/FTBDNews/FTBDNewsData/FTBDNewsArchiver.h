//
//  FTBDNewsArchiver.h
//  BaiduIn100Companies
//
//  Created by wilsonhan on 2018/7/23.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FTBDNewsData;
@class FTBDNews;
@class UIImage;

@interface FTBDNewsArchiver : NSObject

/**
 * 批量存入数据和图片
 * 目前无法存入图片
 */
- (BOOL)saveNews:(NSDictionary<NSString *, FTBDNews *> *)newsDict
           image:(NSDictionary<NSString *, UIImage *> *)imageDict;

/**
 * 单独存储一个news
 * 目前无法存入图片
 */
- (BOOL)saveData:(NSString *)keyword news:(FTBDNews *)news;

- (void)readNews:(NSMutableDictionary *)newsDict;


@end
