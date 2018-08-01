//
//  MyCarlendarView.h
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/11.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FTCalendarView;

@protocol FTCalendarDelegate <NSObject>

@optional
/**
 在日历中选择了一个日期
 */
- (void)calendarView:(FTCalendarView *)calendarView doneWithDate:(NSDate *)date;

/**
 在日历中选择了一段日期
 */
- (void)calendarView:(FTCalendarView *)calendarView doneWithDates:(NSDate *)from to:(NSDate *)to;

@end

/**
 日历控件，用于显示一个可以按月查看的日历
 */
@interface FTCalendarView : UIView

/**
 日历的delegate，用于接收在日历中选择的时间
 */
@property (weak, nonatomic) id<FTCalendarDelegate> delegate;

@end
