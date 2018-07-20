//
//  CalendarOneDayCell.m
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/11.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTCalendarOneDayCell.h"

static const CGFloat FTCalendarOneDayButtonMargin = 6.0;
static const CGFloat FTCalendarOneDayButtonMarginDouble = FTCalendarOneDayButtonMargin * 2;

@interface FTCalendarOneDayCell ()

@property (nonatomic, strong) FTCalendarButton *dayBtn;


@end

@implementation FTCalendarOneDayCell

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化Button
        [self initUI:frame];
    }
    return self;
}

- (void)initUI:(CGRect)frame
{
    self.dayBtn = [FTCalendarButton buttonWithType:UIButtonTypeCustom];
    [self updateCellWithTitle:@"" frame:frame];
    self.dayBtn.userInteractionEnabled = NO;
    [self addSubview:self.dayBtn];
}

- (void)updateCellWithTitle:(NSString *)title frame:(CGRect)frame
{
    [self.dayBtn setTitle:title forState:UIControlStateNormal];
    self.dayBtn.frame = CGRectMake(FTCalendarOneDayButtonMargin, FTCalendarOneDayButtonMargin, CGRectGetWidth(frame) - FTCalendarOneDayButtonMarginDouble, CGRectGetHeight(frame) - FTCalendarOneDayButtonMarginDouble);
//    [self.dayBtn.layer setBorderWidth:1.0];
}

- (void)updateCellWithDateIndex:(NSInteger)index
{
    self.index = index;
}

- (void)updateButtonStyleToSelected
{
    [self.dayBtn.layer setCornerRadius:CGRectGetWidth(self.dayBtn.frame) / 2];
    self.dayBtn.backgroundColor = [UIColor colorWithRed:51/255.0 green:120/255.0 blue:221/255.0 alpha:1/1.0];
    [self.dayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)updateButtonStyleToOriginal
{
    [self.dayBtn.layer setCornerRadius:0.0];
    self.dayBtn.backgroundColor = [UIColor whiteColor];
    [self.dayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

#pragma mark - setter/getter

- (void)updateButtonProperty
{
    
}

@end


