//
//  FTCalendarHeaderCell.m
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/12.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTCalendarHeaderCell.h"
#import "FTCalendarHelper.h"
#import "FTBDResource.h"
#import "FTBDMarcoFunction.h"
#import "EXTScope.h"

static const CGFloat kFTCalendarHeaderHeight = 80;//该view的高度
static const CGFloat kFTCalendarHeaderHalfHeight = kFTCalendarHeaderHeight / 2;//该view高度的一半
static const CGFloat kFTCalendarHeaderAlltimeButtonWidth = 120;//所有时间按钮的宽度
static const CGFloat kFTCalendarHeaderDoneButtonWidth = 48;//确认按钮的宽度
static const CGFloat kFTCalendarHeaderLeftArrowWidth = 20;//左箭头的宽度
static const CGFloat kFTCalendarHeaderLeftArrowMargin = 60;//左箭头距离左边边缘距离
static const CGFloat kFTCalendarHeaderTimeLabelWidth = 60;//左箭头距离左边边缘距离

//用于判断按钮是显示年的view还是显示月的view
static const NSInteger kFTCalendarYearLabelTag = 100;
static const NSInteger kFTCalendarMonthLabelTag = 200;


@interface FTCalendarHeaderCell ()

@property (strong, nonatomic) FTCalendarButton *alltimeBtn;
@property (strong, nonatomic) FTCalendarButton *doneBtn;

@property (strong, nonatomic) UIView *yearView;
@property (strong, nonatomic) UIView *monthView;

@property (strong, nonatomic) FTCalendarHelper *calendarHelper;
@property (strong, nonatomic) NSDate *date;

@end

@implementation FTCalendarHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:246/255.0 green:247/255.0 blue:250/255.0 alpha:1/1.0];
        
        [self initView:frame];
        [self initYearView];
        [self initMonthView];
        
    }
    return self;
}

- (void)initView:(CGRect)frame {
    //左上角日期button 旧
//    self.dateLabelBtn = [FTCalendarButton buttonWithType:UIButtonTypeCustom];
//    self.dateLabelBtn.frame = CGRectMake(0, 0, FTCalendarHeaderDateLabelWidth, FTCalendarHeaderHalfHeight);
//    self.dateLabelBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//    [self addSubview:self.dateLabelBtn];
    
    
    //左上角所有时间button
    self.alltimeBtn = [FTCalendarButton buttonWithType:UIButtonTypeCustom];
    self.alltimeBtn.frame = CGRectMake(0, 0, kFTCalendarHeaderAlltimeButtonWidth, kFTCalendarHeaderHalfHeight);
    [self.alltimeBtn setTitle:@"所有时间" forState:UIControlStateNormal];
    self.alltimeBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:self.alltimeBtn];
    
    //确认按钮
    self.doneBtn = [FTCalendarButton buttonWithType:UIButtonTypeCustom];
    self.doneBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - kFTCalendarHeaderDoneButtonWidth, 0, kFTCalendarHeaderDoneButtonWidth, kFTCalendarHeaderHalfHeight);
    [self.doneBtn setTitle:@"确认" forState:UIControlStateNormal];
    [self.doneBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:120/255.0 blue:221/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    self.doneBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    ft_weakify_self;
    self.doneBtn.btnBlock = ^(UIButton *btn) {
        ft_strongify_self;
        if ([self.delegate respondsToSelector:@selector(headerCellButtonAction:)]) {
            [self.delegate headerCellButtonAction:FTCalendarHeaderActionDone];
        }
    };
    self.alltimeBtn.btnBlock = ^(UIButton *btn) {
        ft_strongify_self;
        if ([self.delegate respondsToSelector:@selector(headerCellButtonAction:)]) {
            [self.delegate headerCellButtonAction:FTCalendarHeaderActionAlltime];
        }
    };
    [self addSubview:self.doneBtn];
}

- (void)initYearView {
    __weak FTCalendarHeaderCell *wSelf = self;
//    ft_weakify_self;
    //←，→两个按钮的block回调
    FTCalendarButtonBlock block = ^(UIButton *btn){
//        ft_strongify_self;
        if ([wSelf.delegate respondsToSelector:@selector(buttonActionMoveYear:)]) {
            NSInteger step = 0;
            if ((btn.tag + 1) == kFTCalendarYearLabelTag){//左箭头
                step = -1;
            } else {//右箭头
                step = 1;
            }
            [wSelf.delegate buttonActionMoveYear:step];
        }
    };
    self.yearView = [self makeDateSwitchViewWithOffset:0 block:block tag:kFTCalendarYearLabelTag];
    [self addSubview:self.yearView];
}

- (void)initMonthView {
    __weak FTCalendarHeaderCell *wSelf = self;
    //←，→两个按钮的block回调
    FTCalendarButtonBlock block = ^(UIButton *btn){
        if ([wSelf.delegate respondsToSelector:@selector(buttonActionMoveMonth:)]) {
            NSInteger step = 0;
            if ((btn.tag + 1) == kFTCalendarMonthLabelTag){//左箭头
                step = -1;
            } else {//右箭头
                step = 1;
            }
            [wSelf.delegate buttonActionMoveMonth:step];
        }
    };
    self.monthView = [self makeDateSwitchViewWithOffset:CGRectGetWidth(self.frame) / 2 block:block tag:kFTCalendarMonthLabelTag];
    [self addSubview:self.monthView];
}

//生成一个View，包含一个left arrow，一个right arrow，一个显示时间的label
- (UIView *)makeDateSwitchViewWithOffset:(NSInteger)offset block:(FTCalendarButtonBlock)block tag:(NSInteger)tag; {
    CGFloat viewWidth = CGRectGetWidth(self.frame) / 2;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(offset, kFTCalendarHeaderHalfHeight, viewWidth, kFTCalendarHeaderHalfHeight)];
    
    int leftWidth = kFTCalendarHeaderLeftArrowMargin;
    
    FTCalendarButton *leftArrow = [FTCalendarButton buttonWithType:UIButtonTypeCustom];
    leftArrow.frame = CGRectMake(leftWidth, 0, kFTCalendarHeaderLeftArrowWidth, kFTCalendarHeaderHalfHeight);
    leftArrow.btnBlock = block;
    leftArrow.tag = tag - 1;
    [leftArrow setImage:[UIImage imageNamed:FTResourceLeftArrowNormal] forState:UIControlStateNormal];
    [leftArrow setImage:[UIImage imageNamed:FTResourceLeftArrowHighlight] forState:UIControlStateHighlighted];
    [view addSubview:leftArrow];
    
    leftWidth += kFTCalendarHeaderLeftArrowWidth;
    
    FTCalendarButton *label = [FTCalendarButton buttonWithType:UIButtonTypeCustom];
    label.tag = tag;
    label.frame = CGRectMake(leftWidth, 0, kFTCalendarHeaderTimeLabelWidth, kFTCalendarHeaderHalfHeight);
    [view addSubview:label];
    
    leftWidth += kFTCalendarHeaderTimeLabelWidth;
    
    FTCalendarButton *rightArrow = [FTCalendarButton buttonWithType:UIButtonTypeCustom];
    rightArrow.frame = CGRectMake(leftWidth, 0, kFTCalendarHeaderLeftArrowWidth, kFTCalendarHeaderHalfHeight);
    rightArrow.btnBlock = block;
    rightArrow.tag = tag + 1;
    [rightArrow setImage:[UIImage imageNamed:FTResourceRightArrowNormal] forState:UIControlStateNormal];
    [rightArrow setImage:[UIImage imageNamed:FTResourceRightArrowHighlight] forState:UIControlStateHighlighted];
    [view addSubview:rightArrow];
    
    return view;
}

#pragma mark - update views

- (void)updateViewWithDate:(NSDate *)date {
    //每次刷新时，先清空所有views，然后重新生成label
    self.date = date;
    [self updateView:self.date];
}

- (void)clearAllViews {
    NSArray *arr = [self subviews];
    for(UIView *view in arr) {
        [view removeFromSuperview];
    }
}

//每次刷新时调用，更新左上角时间label（旧）
//修改为所有时间button，点击后调用delegate，传回所有时间的事件
- (void)updateView:(NSDate *)date {
    //左上角时间Label
//    [self.dateLabelBtn setTitle:[FTCalendarHelper stringOfDate:date] forState:UIControlStateNormal];
//    //判断是否为今天，是则显示（今天）字符串
//    if ([FTCalendarHelper isSameDay:date date2:[NSDate date]]) {
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 60, 40)];
//        label.text = @"(今天)";
//        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//        [self addSubview:label];
//    }
    
    //更新year button title 和 month button title
    NSDateComponents *comp = [FTCalendarHelper components:self.date];
    UIButton *yearBtn = [self.yearView viewWithTag:kFTCalendarYearLabelTag];
    if (yearBtn != nil) {
        [yearBtn setTitle:[NSString stringWithFormat:@"%ld", comp.year] forState:UIControlStateNormal];
    }
    UIButton *monthBtn = [self.monthView viewWithTag:kFTCalendarMonthLabelTag];
    if (monthBtn != nil) {
        [monthBtn setTitle:[NSString stringWithFormat:@"%ld月", comp.month] forState:UIControlStateNormal];
    }
}


@end
