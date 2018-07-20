//
//  FTCalendarButton.m
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/12.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTCalendarButton.h"

@implementation FTCalendarButton


+ (instancetype)buttonWithType:(UIButtonType)buttonType
{
    FTCalendarButton *btn = [super buttonWithType:buttonType];
    [btn initProperty];
    return btn;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperty];
    }
    return self;
}

- (void)initProperty
{
    [self addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    //设置通用属性颜色
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //Alignment
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)btnAction:(UIButton *)sender
{
    if(self.btnBlock) {
        self.btnBlock(sender);
    }
}

@end
