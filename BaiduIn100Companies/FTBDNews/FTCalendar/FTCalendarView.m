//
//  MyCarlendarView.m
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/11.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTCalendarView.h"
#import "FTCalendarHelper.h"
#import "FTCalendarOneDayCell.h"
#import "FTCalendarHeaderCell.h"
#import "FTCalendarWeekTitleCell.h"
#import "FTCalendarButton.h"

static const NSInteger kFTCollectionViewSectionCount = 3;
static const CGFloat kFTMainSectionHeight = 280;

/**
 * 日历CollectionView section index枚举，共三个区
 * 1. 日历头部 FTCalendarHeaderSection
 * 2. 显示周一到周日信息区 FTCalendarWeekTitleSection
 * 3. 显示日期的区 FTCalendarMainSection
 */
typedef NS_ENUM(NSInteger, FTCalendarSectionType) {
    FTCalendarHeaderSection = 0,
    FTCalendarWeekTitleSection,
    FTCalendarMainSection
};

/**
 * 当前日期选择的状态
 * 1. 还没开始选择日期
 * 2. 已经选择了from日期
 * 3. 已经选择了To日期
 */
typedef NS_ENUM(NSInteger, FTCalendarDateSelectedStatusType) {
    FTCalendarDateNotSelected = 0,
    FTCalendarSelectedFromDate,
    FTCalendarSelectedToDate
};


static const int sFTMainSectionEdge = 20;//20

@interface FTCalendarView ()
<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FTCalendarHeaderDelegate>

@property (strong, nonatomic) UICollectionView *calendarCollectionView;

@property (strong, nonatomic) NSDate *currentDate;//当前日期，主要用于标识当前的年和月
@property (strong, nonatomic) NSDate *selectedDate;//选择的日期
@property (strong, nonatomic) NSDate *firstDayOfDate;//本月第一天
@property (assign, nonatomic) NSInteger weekIndexOfFirstDay;//第一天是周几
@property (assign, nonatomic) NSInteger dayCountOfMonth;//本月天数

@property (assign, nonatomic) NSInteger mainSectionCellCount;//日期区Cell个数，可能35个也可能42个
@property (assign, nonatomic) CGFloat mainSectionCellWidth;//日期区Cell宽度
@property (assign, nonatomic) CGFloat mainSectionCellHeight;//日期区Cell高度

//记录选中日期相关属性
@property (strong, nonatomic) NSDate *selectedFromDate;//日期区间：from
@property (strong, nonatomic) NSDate *selectedToDate;//日期区间：to
@property (strong, nonatomic) FTCalendarOneDayCell *selectedFromDateCell;//日期区间Cell：from
@property (strong, nonatomic) FTCalendarOneDayCell *selectedToDateCell;//日期区间Cell：to
@property (strong, nonatomic) FTCalendarOneDayCell *lastSelectedCell;//上一个选中的日期
@property (assign, nonatomic) FTCalendarDateSelectedStatusType dateSelectedStatus;//当前日期选择的状态

@end

@implementation FTCalendarView

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initProperty];
        [self initCollectionView:frame];
        [self initCalendar];
    }
    
    return self;
}

- (void)setHidden:(BOOL)hidden {
    if (hidden) {
        [self.calendarCollectionView reloadData];
    }
    [super setHidden:hidden];
}

/*
 * 初始化Collection View
 */
- (void)initCollectionView:(CGRect)frame {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _calendarCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)) collectionViewLayout:layout];
    _calendarCollectionView.backgroundColor = [UIColor clearColor];
    _calendarCollectionView.delegate = self;
    _calendarCollectionView.dataSource = self;
    //注册Cell
    [_calendarCollectionView registerClass:[FTCalendarHeaderCell class] forCellWithReuseIdentifier:NSStringFromClass([FTCalendarHeaderCell class])];
    [_calendarCollectionView registerClass:[FTCalendarWeekTitleCell class] forCellWithReuseIdentifier:NSStringFromClass([FTCalendarWeekTitleCell class])];
    [_calendarCollectionView registerClass:[FTCalendarOneDayCell class] forCellWithReuseIdentifier:NSStringFromClass([FTCalendarOneDayCell class])];
    [self addSubview:_calendarCollectionView];
}

/**
 * 初始化Calendar
 */
- (void)initCalendar {
    _currentDate = [NSDate date];
    [self calculateDateInfo];
}

- (void)initProperty {
    self.dateSelectedStatus = FTCalendarDateNotSelected;
}

#pragma mark - update/calculate

/**
 * 计算日历中需要用到的一些信息，如
 * 本月第一天是星期几等
 */
- (void)calculateDateInfo {
    self.firstDayOfDate = [FTCalendarHelper firstDayOfMonth:self.currentDate];
    self.weekIndexOfFirstDay = [FTCalendarHelper dayIndexOfWeek:self.firstDayOfDate] - 1;
    self.dayCountOfMonth = [FTCalendarHelper dayCountOfMonth:self.currentDate];
    
    NSLog(@"今天日期%@，1号为一周的第%ld天（第0天为周日），该月共%ld天", [FTCalendarHelper stringOfDate:self.currentDate], self.weekIndexOfFirstDay, self.dayCountOfMonth);
    [self calculateMainSectionCellCount];
}

/**
 * 计算日期区的Cell个数，每次修改日期均需要调用
 */
- (void)calculateMainSectionCellCount
{
    if (self.weekIndexOfFirstDay + self.dayCountOfMonth > 35) {
        self.mainSectionCellCount = 42;
        self.mainSectionCellHeight = kFTMainSectionHeight / 6;
    } else {
        self.mainSectionCellCount = 35;
        self.mainSectionCellHeight = kFTMainSectionHeight / 5;
    }
    self.mainSectionCellWidth = (CGRectGetWidth(self.frame) - sFTMainSectionEdge * 2) / 7;//减去mainsection两边边缘除以7
}

- (void)updateDateWithYear:(NSInteger)yearStep month:(NSInteger)monthStep
{
    self.currentDate = [FTCalendarHelper jumpDate:self.currentDate year:yearStep month:monthStep day:0];
    //更新日期相关属性
    [self calculateDateInfo];
}

//更新current date，index是当月日期的索引
- (void)updateSelectedDateWithIndex:(NSInteger)index
{
    self.selectedDate = [FTCalendarHelper dateFromIndex:index date:self.currentDate];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kFTCollectionViewSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (section == FTCalendarMainSection) ? self.mainSectionCellCount : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    UICollectionViewCell *cell = nil;
    if (section == FTCalendarMainSection) {
        cell = [self collectionView:collectionView cellForMainSection:indexPath];
    } else if (section == FTCalendarHeaderSection) {
        cell = [self collectionView:collectionView cellForHeader:indexPath];
    } else if (section == FTCalendarWeekTitleSection) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FTCalendarWeekTitleCell class]) forIndexPath:indexPath];
    } else {
        NSLog(@"cellForItemAtIndexPath：section错误");
        abort();
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

//每一个Item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    CGSize size;
    if (section == FTCalendarMainSection) {
        size = CGSizeMake(self.mainSectionCellWidth, self.mainSectionCellHeight);
    } else if (section == FTCalendarHeaderSection) {
        size = CGSizeMake(CGRectGetWidth(self.frame), 80);
    } else if (section == FTCalendarWeekTitleSection) {
        size = CGSizeMake(CGRectGetWidth(self.frame) - sFTMainSectionEdge * 2, 60);
    } else {
        NSLog(@"sizeForItemAtIndexPath: section错误");
        abort();
    }
    [collectionView addObserver:self forKeyPath:@"d" options:0 context:nil];
    
    return size;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == FTCalendarMainSection || section == FTCalendarWeekTitleSection) {
        return UIEdgeInsetsMake(0, sFTMainSectionEdge, 0, sFTMainSectionEdge);
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

//点击Item的响应
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //选择日期区的某一天，保存选择的Date，需要修改button的外观
    if (indexPath.section == FTCalendarMainSection) {
        FTCalendarOneDayCell *cell = (FTCalendarOneDayCell *)[collectionView cellForItemAtIndexPath:indexPath];
        //更新selected日期
        if (cell.index != -1) {
            //获取cell对应的日期
            NSDate *dateForCell = [FTCalendarHelper dateFromIndex:cell.index date:self.currentDate];
            if (!dateForCell) {
                NSLog(@"FTCalendarView->didSelectItemAtIndexPath->从Cell获取的日期为空");
                return;
            }
//            if (self.dateSelectedStatus == FTCalendarDateNotSelected) {//当前还没有选择from日期
//                self.selectedFromDate = dateForCell;
//                self.selectedFromDateCell = cell;
//                self.dateSelectedStatus = FTCalendarSelectedFromDate;
//                //如果是同一月才渲染
//                if ([FTCalendarHelper isSameMonth:self.selectedFromDate date2:self.currentDate]) {
//                    [cell updateButtonStyleToSelected];
//                }
//            } else if (self.dateSelectedStatus == FTCalendarSelectedFromDate) {//当前选择了from日期，没有选择to日期
//                self.selectedToDate = dateForCell;
//                self.selectedToDateCell = cell;
//                self.dateSelectedStatus = FTCalendarSelectedToDate;
//                //如果是同一月才渲染
//                if ([FTCalendarHelper isSameMonth:self.selectedToDate date2:self.currentDate]) {
//                    [cell updateButtonStyleToSelected];
//                }
//            } else {//当前已经选了from日期和to日期
//
//            }
            [self updateSelectedDateWithIndex:cell.index];
            //首先清空上次修改的button样式
            if (self.lastSelectedCell != nil) {
                [self.lastSelectedCell updateButtonStyleToBackup];
            }
            //如果是同一月才渲染
            if ([FTCalendarHelper isSameMonth:self.selectedDate date2:self.currentDate]) {
                [cell updateButtonStyleToSelected];
                self.lastSelectedCell = cell;
            }
        }
    }
}

#pragma mark - FTCalendarHeaderDelegate

//改变月份
- (void)buttonActionMoveMonth:(NSInteger)step
{
    [self updateDateWithYear:0 month:step];
    [self.calendarCollectionView reloadData];
}

//改变年份
- (void)buttonActionMoveYear:(NSInteger)step
{
    [self updateDateWithYear:step month:0];
    [self.calendarCollectionView reloadData];
}

- (void)headerCellButtonAction:(FTCalendarHeaderActionType)actionType
{
    if (actionType == FTCalendarHeaderActionDone) {//确认按钮响应，通知上层隐藏日历
        if ([self.delegate respondsToSelector:@selector(calendarView:doneWithDate:)]) {
            [self.delegate calendarView:(FTCalendarView *)self doneWithDate:self.selectedDate];
        }
    } else if (actionType == FTCalendarHeaderActionAlltime) {//所有时间按钮响应，传回空date
        [self clearSelectedState];
        if ([self.delegate respondsToSelector:@selector(calendarView:doneWithDate:)]) {
            [self.delegate calendarView:(FTCalendarView *)self doneWithDate:nil];
        }
    }
}

#pragma mark - private method

//返回main section中每一天的cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForMainSection:(NSIndexPath *)indexPath
{
    //该月第一天是周几
    NSInteger item = indexPath.row;
    
    FTCalendarOneDayCell *cell = (FTCalendarOneDayCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FTCalendarOneDayCell class]) forIndexPath:indexPath];
    static int index = -1;
    
    [cell updateCellWithDateIndex:-1];
    [cell updateButtonStyleToDefault];
    //判断当前item的cell是否应该开始显示日期
    if (item >= self.weekIndexOfFirstDay && index < self.dayCountOfMonth) {
        if (index == -1) {
            index = 0;
        }
        [cell updateCellWithDateIndex:index];
        [cell updateCellWithTitle:[NSString stringWithFormat:@"%d", index + 1] frame:CGRectMake(0, 0, self.mainSectionCellWidth, self.mainSectionCellHeight)];
        NSDate *indexDate = [FTCalendarHelper dateFromIndex:index date:self.currentDate];
        //判断是否为周六周天
        NSInteger weekday = [FTCalendarHelper dayIndexOfWeek:indexDate];
        if (weekday == 1 || weekday == 7) {
            [cell updateButtonStyleToWeekend];
        }
        //判断当前cell是否为今天，是则修改button为今天的样式
        if ([FTCalendarHelper isSameDay:indexDate date2:[NSDate date]]) {
            [cell updateButtonStyleToToday];
        }
        //判断当前cell是否是被选中的cell，是则修改button为被选中的样式
        if ([FTCalendarHelper isSameDay:indexDate date2:self.selectedDate]) {
            [cell updateButtonStyleToSelected];
            self.lastSelectedCell = cell;
        }
        index++;
    } else {
        [cell updateCellWithTitle:@"" frame:CGRectMake(0, 0, self.mainSectionCellWidth, self.mainSectionCellHeight)];
    }
    

    //当item达到最后一个时，重置index到-1，
    //mainSectionCellCount是当前日期区需要显示的item数，35个或者42个，每个月可能不一样。
    if (item == self.mainSectionCellCount - 1) {
        index = -1;
    }
    
    return cell;
}

//返回header cell
- (FTCalendarHeaderCell *)collectionView:(UICollectionView *)collectionView cellForHeader:(NSIndexPath *)indexPath
{
    FTCalendarHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FTCalendarHeaderCell class]) forIndexPath:indexPath];
    FTCalendarHeaderCell* tc = (FTCalendarHeaderCell *)cell;
    [tc updateViewWithDate:self.currentDate];
    tc.delegate = self;
    return cell;
}

- (void)clearSelectedState
{
    self.lastSelectedCell = nil;
    self.selectedDate = nil;
}


@end
