//
//  CalendarOneDayCell.h
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/11.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTCalendarButton.h"

/**
 * 日历主体中每一天的Cell
 */
@interface FTCalendarOneDayCell : UICollectionViewCell

//当前cell对应的日期index
@property (nonatomic, assign) NSInteger index;

- (void)updateCellWithTitle:(NSString *)title frame:(CGRect)frame;

- (void)updateCellWithDateIndex:(NSInteger)index;

/**
 * 更新button样式为选中后的样式
 */
- (void)updateButtonStyleToSelected;

/**
 * 更新button样式为备份的样式
 */
- (void)updateButtonStyleToBackup;

/**
 * 更新button样式为默认样式
 */
- (void)updateButtonStyleToDefault;

/**
 * 更新button样式为当天日期样式
 */
- (void)updateButtonStyleToToday;

/**
 * 更新button样式为周六周天
 */
- (void)updateButtonStyleToWeekend;

@end
