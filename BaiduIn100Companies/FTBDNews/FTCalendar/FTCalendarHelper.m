//
//  FTCalendar.m
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/11.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTCalendarHelper.h"

static const NSInteger sFTCalendarUnitYearMonthDay = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
static NSString *sFTDateFormatString = @"%ld-%ld-%ld";

static NSCalendar *sFTCalendar;

@implementation FTCalendarHelper


//static FTCalendarHelper *instance = nil;


//+ (instancetype)sharedInstance
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if(instance == nil) {
//            instance = [[FTCalendarHelper alloc] init];
//        }
//    });
//    return instance;
//}

#pragma mark - LifeCycle

//+ (instancetype)allocWithZone:(struct _NSZone *)zone
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if(instance == nil) {
//            instance = [super allocWithZone:zone];
//        }
//    });
//    return instance;
//}
//
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        _calendar = [NSCalendar currentCalendar];
//        [_calendar setFirstWeekday:2];
//    }
//    return self;
//}
//
//- (id)copy
//{
//    return self;
//}

+ (void)initialize
{
    sFTCalendar = [NSCalendar currentCalendar];
}



#pragma mask - Getter/Setter



//返回当月的天数
+ (NSInteger)dayCountOfMonth:(NSDate *)date
{
    if(!date) {
        return -1;
    }
    
    NSRange range = [sFTCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}

- (NSInteger)dayCountOfMonth
{
    return [FTCalendarHelper dayCountOfMonth:[NSDate date]];
}

//返回该天是周几
+ (NSInteger)dayIndexOfWeek:(NSDate *)date
{
    if(!date) {
        return -1;
    }
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps = [sFTCalendar components:NSCalendarUnitWeekday fromDate:date];
    NSInteger index = comps.weekday;
    return index;
}

+ (NSInteger)dayIndexOfWeek
{
    return [self dayIndexOfWeek:[NSDate date]];
}

//获取该月的第一天
+ (NSDate *)firstDayOfMonth:(NSDate *)date
{
    if(!date) {
        return nil;
    }
    
    NSDate *beginDate = nil;
    double interval = 0;
    if(![sFTCalendar rangeOfUnit:NSCalendarUnitMonth
                         startDate:&beginDate
                          interval:&interval
                           forDate:date]) {
        return nil;
    }
    return beginDate;
}

+ (NSDate *)firstDayOfMonth
{
    return [self firstDayOfMonth:[NSDate date]];
}

//返回时间字符串
+ (NSString *)stringOfDate:(NSDate *)date
{
    if(!date) {
        return @"";
    }
    
    NSDateComponents *components = [self components:date];
    NSString *str = [NSString stringWithFormat:sFTDateFormatString, components.year, components.month, components.day];
    return str;
}


+ (NSDate *)dateFromIndex:(NSInteger)index date:(NSDate *)date
{
    return [self moveDay:[self firstDayOfMonth:date] step:index];
}

+ (NSString *)stringOfDate
{
    return [self stringOfDate:[NSDate date]];
}

+ (NSDateComponents *)components:(NSDate *)date
{
    NSDateComponents *components = [sFTCalendar components:sFTCalendarUnitYearMonthDay fromDate:date];
    return components;
}

#pragma mark -Tools

/**
 * 切换月份123
 */
+ (NSDate *)moveMonth:(NSDate *)date step:(NSInteger)step
{
    return [self jumpDate:date year:0 month:step day:0];
}

/**
 * 切换年份123
 */
+ (NSDate *)moveYear:(NSDate *)date step:(NSInteger)step
{
    return [self jumpDate:date year:step month:0 day:0];
}

/**
 * 切换天数123
 */
+ (NSDate *)moveDay:(NSDate *)date step:(NSInteger)step
{
    return [self jumpDate:date year:0 month:0 day:step];
}

/**
 * 跳转日期
 */
+ (NSDate *)jumpDate:(NSDate *)date year:(NSInteger)yearStep month:(NSInteger)monthStep day:(NSInteger)dayStep
{
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.year = yearStep;
    comp.month = monthStep;
    comp.day = dayStep;
    NSDate *newDate = [sFTCalendar dateByAddingComponents:comp toDate:date options:NSCalendarMatchStrictly];
    return newDate;
}

//比较是否同一天
+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2
{
    if(date1 == nil || date2 == nil) {
        return NO;
    }
    NSDateComponents *c1 = [self components:date1];
    NSDateComponents *c2 = [self components:date2];
    return (c1.day == c2.day) && (c1.month == c2.month) && (c1.year == c2.year);
}

//比较是否同一月
+ (BOOL)isSameMonth:(NSDate *)date1 date2:(NSDate *)date2
{
    if(date1 == nil || date2 == nil) {
        return NO;
    }
    NSDateComponents *c1 = [FTCalendarHelper components:date1];
    NSDateComponents *c2 = [FTCalendarHelper components:date2];
    return (c1.month == c2.month) && (c1.year == c2.year);
}

@end
