//
//  FTCalendar.h
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/11.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTCalendarHelper : NSObject

//@property (nonatomic, strong) NSCalendar *calendar;


//+ (instancetype)sharedInstance;

/**
 * 获取指定月的天数
 */
+ (NSInteger)dayCountOfMonth:(NSDate *)date;

/**
 * 获取第一天是周几
 */
+ (NSInteger)dayIndexOfWeek:(NSDate *)date;
+ (NSInteger)dayIndexOfWeek;

/**
 * 获取本月第一天的Date
 */
+ (NSDate *)firstDayOfMonth:(NSDate *)date;
+ (NSDate *)firstDayOfMonth;

/**
 * 返回时间字符串
 */
+ (NSString *)stringOfDate:(NSDate *)date;
+ (NSString *)stringOfDate;

/**
 * 切换月份
 */
+ (NSDate *)moveMonth:(NSDate *)date step:(NSInteger)step;

/**
 * 切换年份
 */
+ (NSDate *)moveYear:(NSDate *)date step:(NSInteger)step;

/**
 * 切换天数
 */
+ (NSDate *)moveDay:(NSDate *)date step:(NSInteger)step;

/**
 * 跳转日期
 */
+ (NSDate *)jumpDate:(NSDate *)date year:(NSInteger)yearStep month:(NSInteger)monthStep day:(NSInteger)dayStep;

/**
 * 根据date计算该月的第index天的date
 */
+ (NSDate *)dateFromIndex:(NSInteger)index date:(NSDate *)date;

/**
 * 比较是否同一年同一月同一天
 */
+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2;

/**
 * 比较是否同一年的同一月
 */
+ (BOOL)isSameMonth:(NSDate *)date1 date2:(NSDate *)date2;


+ (NSDateComponents *)components:(NSDate *)date;

@end
