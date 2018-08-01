//
//  FTCalendarHeaderCell.h
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/12.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTCalendarButton.h"

/**
 * 用于FTCalendarHeaderDelegate中的按钮事件判断
 */
typedef NS_ENUM(NSUInteger, FTCalendarHeaderActionType) {
    FTCalendarHeaderActionDone = 0,
    FTCalendarHeaderActionAlltime,
    FTCalendarHeaderActionReserve
};

@protocol FTCalendarHeaderDelegate <NSObject>

- (void)buttonActionMoveYear:(NSInteger)step;
- (void)buttonActionMoveMonth:(NSInteger)step;

- (void)headerCellButtonAction:(FTCalendarHeaderActionType)actionType;

@end

@interface FTCalendarHeaderCell : UICollectionViewCell

@property (strong, nonatomic) id<FTCalendarHeaderDelegate> delegate;

/**
 * 每次刷新Collection View时调用该方法更新Header Cell中的View
 */
- (void)updateViewWithDate:(NSDate *)date;

@end
