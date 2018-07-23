//
//  CalendarOneDayCell.m
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/11.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTCalendarOneDayCell.h"

static const CGFloat sFTCalendarOneDayButtonMargin = 8.0;

@interface FTCalendarOneDayCell ()
{
    CGFloat _oldCornerRadius;
    UIColor *_oldBackgroundColor;
    UIColor *_oldTitleColor;
    CGFloat _oldBorderWidth;
    CGColorRef _oldBorderColor;
}

@property (nonatomic, strong) FTCalendarButton *dayBtn;


@end

@implementation FTCalendarOneDayCell

#pragma mark - life cycle

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
    [self initDefaultStyle];
    [self addSubview:self.dayBtn];
//    self.layer.borderWidth = 1.0;

}

- (void)updateCellWithTitle:(NSString *)title frame:(CGRect)frame
{
    [self.dayBtn setTitle:title forState:UIControlStateNormal];
    
    //button为圆形或正方形，计算button的坐标
    CGFloat btnWidth = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame)) - sFTCalendarOneDayButtonMargin;//cell的高宽不一致，获取最小值
    CGFloat marginLeft = (CGRectGetWidth(frame) - btnWidth) / 2;
    CGFloat marginUp = (CGRectGetHeight(frame) - btnWidth) / 2;
    
    self.dayBtn.frame = CGRectMake(marginLeft, marginUp, btnWidth, btnWidth);
//    [self.dayBtn.layer setBorderWidth:1.0];
}

- (void)updateCellWithDateIndex:(NSInteger)index
{
    self.index = index;
}

- (void)updateButtonStyleToSelected
{
    [self saveCurrentStyle];
    
    [self.dayBtn.layer setCornerRadius:CGRectGetWidth(self.dayBtn.frame) / 2];
    [self.dayBtn setBackgroundColor:[UIColor colorWithRed:51/255.0 green:120/255.0 blue:221/255.0 alpha:1/1.0]];
    [self.dayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

//恢复上一个5条属性，角半径，背景颜色，字体颜色，边的宽度，边的颜色
- (void)updateButtonStyleToBackup
{
    [self.dayBtn.layer setBorderWidth:_oldBorderWidth];
    [self.dayBtn.layer setCornerRadius:_oldCornerRadius];
    [self.dayBtn setBackgroundColor:_oldBackgroundColor];
    [self.dayBtn setTitleColor:_oldTitleColor forState:UIControlStateNormal];
}

//恢复成默认样式
- (void)updateButtonStyleToDefault
{
    [self initDefaultStyle];
}

/**
 * 更新button样式为当天日期样式
 */
- (void)updateButtonStyleToToday
{
    [self saveCurrentStyle];
    
    [self.dayBtn.layer setBorderColor:[UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0].CGColor];
    [self.dayBtn.layer setBorderWidth:0.5];
    [self.dayBtn.layer setCornerRadius:CGRectGetWidth(self.dayBtn.frame) / 2];
    
}

//设置默认样式
- (void)initDefaultStyle
{
    [self.dayBtn.layer setCornerRadius:0.0];
    [self.dayBtn setBackgroundColor:[UIColor whiteColor]];
    [self.dayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.dayBtn.layer setBorderWidth:0.0];
    [self.dayBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [self saveCurrentStyle];
}

//保存当前样式
- (void)saveCurrentStyle
{
    _oldCornerRadius = [self.dayBtn.layer cornerRadius];
    _oldBackgroundColor = [self.dayBtn backgroundColor];
    _oldTitleColor = [self.dayBtn titleColorForState:UIControlStateNormal];
    _oldBorderWidth = [self.dayBtn.layer borderWidth];
    _oldBorderColor = [self.dayBtn.layer borderColor];
}

@end


