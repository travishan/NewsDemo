//
//  FTBDNewsViewController.m
//  BaiduIn100Companies
//
//  Created by wilsonhan on 2018/7/17.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTBDNewsViewController.h"
#import "FTBDNewsDetailsController.h"
#import "FTBDNewsData.h"
#import "FTBDNewsFetcher.h"
#import "FTBDNewsDataManager.h"
#import "FTBDNewsTableViewCell.h"
#import "FTCalendarButton.h"
#import "FTCalendarView.h"
#import "FTCalendarHelper.h"
#import "FTBDResource.h"

static const CGFloat FTBDSearchTextFieldHeight = 40;//搜索框高度
static const CGFloat FTBDSearchTextFieldLeftMargin = 10;//搜索框距离左边宽度
static const CGFloat FTBDTabelViewCellHeight = 100;
static const CGFloat FTBDLayerBorderWidth = 0.5f;
static const CGFloat FTBDCalenderViewHeight = 420;
static const CGFloat FTBDDateFilterBottomArrowWidth = 40;

//UITable Cell Identifer
static NSString *FTBDNewsTableViewCellIdentifer = @"FTBDNewsTableViewCell";
static NSString *FTBDNewsSearchDefaultKey = @"富途";
static NSString *FTBDNewsSearchPlaceholder = @"请输入要搜索的关键字";
static NSString *FTBDNewsMainViewTitle = @"热点新闻";
static NSString *FTBDNewsDateFilterStr = @"日期筛选";

@interface FTBDNewsViewController ()
<UITextFieldDelegate, FTBDNewsDelegate, UITableViewDelegate, UITableViewDataSource,
FTCalendarDelegate>
{
    CGFloat _mainViewYPosition;//搜索框的Y轴坐标，在顶部状态栏和导航栏的下面
    CGFloat _mainWidth;
    CGFloat _mainHeight;
    
    NSString *_currentKeyword;
    NSArray *_currentNews;
    
    BOOL _isFilterDate;//是否筛选日期
}

//UI
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UITableView *newsTableView;
@property (nonatomic, strong) UIView *dateFilterAbovedView;//开启时间过滤后的View，显示过滤的时间labe和button
@property (nonatomic, strong) UIButton *dateFilterButton;//开启时间过滤后的Button，显示过滤的时间
@property (nonatomic, strong) UIButton *dateFilterArrowButton;//开始时间过滤后的button，显示箭头
@property (nonatomic, strong) FTCalendarView *calendarView;
//Data
@property (nonatomic, strong) FTBDNewsDataManager *newsManager;
//Date
@property (nonatomic, strong) NSDate *selectedDate;

@end

@implementation FTBDNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initProperty];
    [self initViews];
    
//    [_newsManager testImageDownload];//测试API图片缓存代码
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Initial

- (void)initViews
{
    //导航栏相关
    self.navigationItem.title = FTBDNewsMainViewTitle;
    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
    //创建刷新新闻按钮
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshNewsAction:)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
    
    //搜索框与日期筛选平分屏幕的宽度
    CGFloat searchTextFieldWidth = _mainWidth / 2;
    
    //搜索框 View+UITextField
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, _mainViewYPosition, searchTextFieldWidth, FTBDSearchTextFieldHeight)];
    view.layer.borderWidth = FTBDLayerBorderWidth;
    view.backgroundColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1];
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(FTBDSearchTextFieldLeftMargin, 0, view.frame.size.width - FTBDSearchTextFieldLeftMargin, FTBDSearchTextFieldHeight)];
    self.searchTextField.text = FTBDNewsSearchDefaultKey;
    self.searchTextField.placeholder = FTBDNewsSearchPlaceholder;
    self.searchTextField.delegate = self;
    [self.searchTextField setReturnKeyType:UIReturnKeyGoogle];
    [view addSubview:self.searchTextField];
    [self.view addSubview:view];
    
    //日期筛选View  与搜索框并排，宽度相同
    UIView *dateFilterView = [[UIView alloc] initWithFrame:CGRectMake(searchTextFieldWidth, _mainViewYPosition, searchTextFieldWidth, FTBDSearchTextFieldHeight)];
    dateFilterView.layer.borderWidth = FTBDLayerBorderWidth;
    [self.view addSubview:dateFilterView];
    //日期筛选框上的默认按钮，显示日期筛选
    FTCalendarButton *placeholderButton = [FTCalendarButton buttonWithType:UIButtonTypeCustom];
    placeholderButton.frame = CGRectMake(0, 0, searchTextFieldWidth, FTBDSearchTextFieldHeight);
    [placeholderButton setTitle:FTBDNewsDateFilterStr forState:UIControlStateNormal];
    __weak FTBDNewsViewController *weakSelf = self;
    placeholderButton.btnBlock = ^(UIButton *btn) {
        //弹出日历View
        [weakSelf showCalendar];
    };
    [dateFilterView addSubview:placeholderButton];
    //开启日期筛选之后显示的View
    self.dateFilterAbovedView = [[UIView alloc] initWithFrame:CGRectMake(searchTextFieldWidth, _mainViewYPosition, searchTextFieldWidth, FTBDSearchTextFieldHeight)];
    self.dateFilterAbovedView.backgroundColor = [UIColor whiteColor];
    self.dateFilterAbovedView.layer.borderWidth = FTBDLayerBorderWidth;
    self.dateFilterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, searchTextFieldWidth - FTBDDateFilterBottomArrowWidth, FTBDSearchTextFieldHeight)];
    [self.dateFilterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.dateFilterButton addTarget:self action:@selector(dateFilterBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.dateFilterButton addTarget:self action:@selector(dateFilterBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
    self.dateFilterArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dateFilterArrowButton setFrame:CGRectMake(searchTextFieldWidth - FTBDDateFilterBottomArrowWidth, 0, FTBDDateFilterBottomArrowWidth, FTBDSearchTextFieldHeight)];
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceDownArrowNormal] forState:UIControlStateNormal];
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceDownArrowHighlight] forState:UIControlStateHighlighted];
    [self.dateFilterArrowButton addTarget:self action:@selector(dateFilterBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.dateFilterAbovedView addSubview:self.dateFilterArrowButton];
    [self.dateFilterAbovedView addSubview:self.dateFilterButton];
    [self.view addSubview:self.dateFilterAbovedView];
    self.dateFilterAbovedView.hidden = YES;
    
    //Calendar View
    self.calendarView = [[FTCalendarView alloc] initWithFrame:CGRectMake(0, _mainHeight - FTBDCalenderViewHeight, _mainWidth, FTBDCalenderViewHeight)];
    self.calendarView.hidden = YES;
    self.calendarView.delegate = self;
    [self.view addSubview:self.calendarView];
    
    //Table view
    CGFloat tableHeightOffset = _mainViewYPosition + FTBDSearchTextFieldHeight;
    self.newsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableHeightOffset, _mainWidth, _mainHeight - tableHeightOffset) style:UITableViewStylePlain];
    self.newsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.newsTableView.dataSource = self;
    self.newsTableView.delegate = self;
    [self.newsTableView registerClass:[FTBDNewsTableViewCell class] forCellReuseIdentifier:FTBDNewsTableViewCellIdentifer];
    
    [self.view addSubview:self.newsTableView];
}

- (void)initProperty
{
    _mainViewYPosition = [self calculateMainViewHeightOffset];
    _mainWidth = [UIScreen mainScreen].bounds.size.width;
    _mainHeight = [UIScreen mainScreen].bounds.size.height;
    
    _newsManager = [FTBDNewsDataManager sharedInstance];
    _newsManager.delegate = self;
    
    _currentKeyword = @"富途";
    _isFilterDate = NO;//是否开启了日期筛选
}

- (void)initDateFilterView
{
    
}

#pragma mark - private method

//调用NewsManager方法异步拉取新闻，通过协议方法notifyData接收返回消息
- (void)searchNews:(NSString *)keyword date:(NSDate *)date
{
    if([keyword isEqualToString:@""]) {
        return;
    }
    [_newsManager pullBaiduNews:keyword date:date];
}

//弹出日历
- (void)showCalendar
{
    self.calendarView.hidden = NO;
    [self.view bringSubviewToFront:self.calendarView];
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceUpArrowNormal] forState:UIControlStateNormal];
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceUpArrowHighlight] forState:UIControlStateHighlighted];
}

//隐藏日历
- (void)hiddenCalendar
{
    self.calendarView.hidden = YES;
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceDownArrowNormal] forState:UIControlStateNormal];
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceDownArrowHighlight] forState:UIControlStateHighlighted];
}

- (void)resetFilter
{
    self.selectedDate = nil;
    _isFilterDate = NO;
    self.dateFilterAbovedView.hidden = YES;
}

- (void)beginFilter:(NSDate *)date
{
    self.selectedDate = date;
    _isFilterDate = YES;
    self.dateFilterAbovedView.hidden = NO;
    [self.dateFilterButton setTitle:[FTCalendarHelper stringOfDate:date] forState:UIControlStateNormal];
}

//更新Keyword，将tableview拉回顶部，同时拉取数据
- (void)refreshKeywordAndNews
{
//    [self resetFilter];//刷新新闻不应该重置日期过滤
    [self.newsTableView setContentOffset:CGPointZero animated:YES];
    
    _currentKeyword = self.searchTextField.text;
    NSLog(@"输入的搜索关键字 = %@", _currentKeyword);
    [self searchNews:_currentKeyword date:self.selectedDate];
}

- (void)updateKeyword:(NSString *)kw
{
    _currentKeyword = kw;
}

#pragma mark - callback/action

//刷新新闻按钮响应事件
- (void)refreshNewsAction:(UIBarButtonItem *)sender
{
    //如果键盘是first responder，则resign，之后会自动调用刷新方法
    if([self.searchTextField isFirstResponder]) {
        [self.searchTextField resignFirstResponder];
    } else {//如果键盘不是first respnder，则直接调用刷新方法
        [self refreshKeywordAndNews];
    }
}


//dateFilterButton按下事件，用于通知dateFilterArrowButton事件，主要是为了显示箭头被按下的动画效果
- (void)dateFilterBtnTouchDown:(UIButton *)sender
{
    self.dateFilterArrowButton.highlighted = YES;
}

//dateFilterButtons松开事件
- (void)dateFilterBtnTouchUpInside:(UIButton *)sender
{
    if(sender == self.dateFilterArrowButton) {//真实的时间过滤器显示日历的button事件响应
        if(self.calendarView.hidden) {
            [self showCalendar];
        } else {
            [self hiddenCalendar];
        }
    } else if(sender == self.dateFilterButton) {//发送消息给dateFilterArrowButton
        self.dateFilterArrowButton.highlighted = NO;
        [self.dateFilterArrowButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}


#pragma mark - touch callback

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.searchTextField resignFirstResponder];
}

#pragma mark - UITabelViewDelegate


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTBDNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FTBDNewsTableViewCellIdentifer];
    
    NSInteger index = indexPath.row;
    FTBDNewsData *data = [_currentNews objectAtIndex:index];
    if(data == nil) {
        return cell;
    }
    
    //获取对应的UIImage，先判断是否有ImageURL
    UIImage *image = nil;
//    if(![data.imageUrls isEqual:[NSNull null]]) {
//        image = [self.newsManager imageForId:data.newsId];
//        if(image == nil) {
//            [self.newsManager pullNewsImage:data cellId:index];
//        }
//    }
    
    [cell updateImageView:image title:data.title time:data.timeStr frame:CGRectMake(0, index * FTBDTabelViewCellHeight, CGRectGetWidth([UIScreen mainScreen].bounds), FTBDTabelViewCellHeight)];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _currentNews.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FTBDTabelViewCellHeight;
}

//点击UITableView row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    if(index < 0) {
        NSLog(@"点击了第%ld行，行数竟然是负数？", indexPath.row);
        return;
    }
    FTBDNewsData *data = [_currentNews objectAtIndex:index];
    NSString *url = data.url;
    FTBDNewsDetailsController *controller = [[FTBDNewsDetailsController alloc] init];
    [controller setupURL:url];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UITextFieldDelegate

//textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchTextField resignFirstResponder];
    return YES;
}

//textfield
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self refreshKeywordAndNews];
}

#pragma mark - FTBDNewsDelegate

//通知新闻拉取结果
- (void)notifyData:(NSArray *)news
{
    _currentNews = news;
    __weak FTBDNewsViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.newsTableView reloadData];
    });
}

- (void)notifyImageDownload:(NSInteger)cellId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellId inSection:0];
        [self.newsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark - FTCalendarDelegate

//日历中点击确认，隐藏日历，处理传回的日期
- (void)doneWithDate:(NSDate *)date
{
    [self hiddenCalendar];
    NSLog(@"date: %@", [FTCalendarHelper stringOfDate:date]);
    [self updateDateFilter:date];
}

//日历中点击确认，隐藏日历，处理传回的一段日期
- (void)doneWithDates:(NSDate *)from to:(NSDate *)to
{
    
}

#pragma mark - date filter

- (void)updateDateFilter:(NSDate *)date
{
    if(date == nil) {//不过滤日期
        [self resetFilter];
    } else {
        [self beginFilter:date];
    }
    [self.newsManager requireNews:_currentKeyword date:date];
}

#pragma mark - Tools

//计算状态栏加上导航栏的高度
- (CGFloat)calculateMainViewHeightOffset
{
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navRect = self.navigationController.navigationBar.frame;
    return statusRect.size.height + navRect.size.height;
}



@end