//
//  FTCalendarWeekTitleCell.m
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/12.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTCalendarWeekTitleCell.h"

@implementation FTCalendarWeekTitleCell

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWeekTitleUI:frame];
    }
    return self;
}

- (void)initWeekTitleUI:(CGRect)frame
{
    NSArray *weekNameArr = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    CGFloat btnWidth = CGRectGetWidth(frame) / 7;
    CGFloat btnHeight = CGRectGetHeight(frame);
    for(int i = 0; i < 7; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:[weekNameArr objectAtIndex:i] forState:UIControlStateNormal];
        btn.frame = CGRectMake(i * btnWidth, 0, btnWidth, btnHeight);
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn.layer setBorderWidth:1.0];
        [self addSubview:btn];
    }

    UILabel *underLine = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(frame) - 20, CGRectGetWidth(frame), 1)];
    underLine.backgroundColor = [UIColor grayColor];
    [self addSubview:underLine];
}

@end
