//
//  MyCarlendarView.h
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/11.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FTCalendarDelegate <NSObject>

@optional
- (void)doneWithDate:(NSDate *)date;
- (void)doneWithDates:(NSDate *)from to:(NSDate *)to;

@end

/**
 * 日历控件，用于显示一个可以按月查看的日历
 */
@interface FTCalendarView : UIView

@property (nonatomic, strong) id<FTCalendarDelegate> delegate;

@end
