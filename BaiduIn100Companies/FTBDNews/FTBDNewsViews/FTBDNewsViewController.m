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
static const CGFloat FTBDNoNewsLabelWidth = 200;
static const CGFloat FTBDNoNewsLabelHeight = 40;


//UITable Cell Identifer
static NSString *FTBDNewsTableViewCellIdentifer = @"FTBDNewsTableViewCell";
static NSString *FTBDNewsSearchDefaultKey = @"富途";
static NSString *FTBDNewsSearchPlaceholder = @"请输入要搜索的关键字";
static NSString *FTBDNewsMainViewTitle = @"热点新闻";
static NSString *FTBDNewsDateFilterStr = @"日期筛选";
static NSString *FTBDNoNewsMessage = @"当前没有新闻可以显示";

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
    NSInteger _recursion;//用于记录请求数据和数据通知
}

//UI
@property (strong, nonatomic) UIView *searchBackgroundView;
@property (strong, nonatomic) UITextField *searchTextField;
//没有开启日期过滤的日期过滤view和按钮
@property (strong, nonatomic) UIView *dateFilterView;
@property (strong, nonatomic) FTCalendarButton *placeholderButton;
//开启时间过滤后的View
@property (strong, nonatomic) UIView *dateFilterAbovedView;//开启时间过滤后的View，显示过滤的时间labe和button
@property (strong, nonatomic) UIButton *dateFilterButton;//开启时间过滤后的Button，显示过滤的时间
@property (strong, nonatomic) UIButton *dateFilterArrowButton;//开始时间过滤后的button，显示箭头

@property (strong, nonatomic) FTCalendarView *calendarView;

@property (strong, nonatomic) UITableView *newsTableView;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@property (strong, nonatomic) UILabel *noNewsMessageLabel;
//Data
@property (strong, nonatomic) FTBDNewsDataManager *newsManager;
//Date
@property (strong, nonatomic) NSDate *selectedDate;

@end

@implementation FTBDNewsViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initProperty];
    [self initViews];
    
//    [_newsManager testImageDownload];//测试API图片缓存代码
    
    [self.newsManager requireNews:_currentKeyword date:nil];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    //搜索框与日期筛选平分屏幕的宽度
    CGFloat searchTextFieldWidth = width / 2;
    //搜索框
    self.searchBackgroundView.frame = CGRectMake(0, _mainViewYPosition, searchTextFieldWidth, FTBDSearchTextFieldHeight);
    self.searchTextField.frame = CGRectMake(FTBDSearchTextFieldLeftMargin, 0, searchTextFieldWidth - FTBDSearchTextFieldLeftMargin, FTBDSearchTextFieldHeight);
    //日期筛选框
    self.dateFilterView.frame = CGRectMake(searchTextFieldWidth, _mainViewYPosition, searchTextFieldWidth, FTBDSearchTextFieldHeight);
    self.placeholderButton.frame = CGRectMake(0, 0, searchTextFieldWidth, FTBDSearchTextFieldHeight);
    //开启日期筛选后的日期筛选框
    self.dateFilterAbovedView.frame = CGRectMake(searchTextFieldWidth, _mainViewYPosition, searchTextFieldWidth, FTBDSearchTextFieldHeight);
    self.dateFilterButton.frame = CGRectMake(0, 0, searchTextFieldWidth - FTBDDateFilterBottomArrowWidth, FTBDSearchTextFieldHeight);
    self.dateFilterArrowButton.frame = CGRectMake(searchTextFieldWidth - FTBDDateFilterBottomArrowWidth, 0, FTBDDateFilterBottomArrowWidth, FTBDSearchTextFieldHeight);
    //calendar view
    self.calendarView.frame = CGRectMake(0, height - FTBDCalenderViewHeight, width, FTBDCalenderViewHeight);
    //table view
    CGFloat tableHeightOffset = _mainViewYPosition + FTBDSearchTextFieldHeight;
    self.newsTableView.frame = CGRectMake(0, tableHeightOffset, width, height - tableHeightOffset);
    
    self.noNewsMessageLabel.frame = CGRectMake((width - FTBDNoNewsLabelWidth) / 2, (height - FTBDNoNewsLabelHeight) / 2, FTBDNoNewsLabelWidth, FTBDNoNewsLabelHeight);
    self.indicatorView.center = CGPointMake(width / 2, height / 2);
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
    
    //搜索框 View+UITextField
    self.searchBackgroundView = [[UIView alloc] init];
    self.searchBackgroundView.layer.borderWidth = FTBDLayerBorderWidth;
    self.searchBackgroundView.backgroundColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1];
    
    self.searchTextField = [[UITextField alloc] init];
    self.searchTextField.text = FTBDNewsSearchDefaultKey;
    self.searchTextField.placeholder = FTBDNewsSearchPlaceholder;
    self.searchTextField.delegate = self;
    [self.searchTextField setReturnKeyType:UIReturnKeyGoogle];
    [self.searchBackgroundView addSubview:self.searchTextField];
    [self.view addSubview:self.searchBackgroundView];
    
    //日期筛选View  与搜索框并排，宽度相同
    self.dateFilterView = [[UIView alloc] init];
    self.dateFilterView.layer.borderWidth = FTBDLayerBorderWidth;
    [self.view addSubview:self.dateFilterView];
    //日期筛选框上的默认按钮，显示日期筛选
    self.placeholderButton = [FTCalendarButton buttonWithType:UIButtonTypeCustom];
    [self.placeholderButton setTitle:FTBDNewsDateFilterStr forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    self.placeholderButton.btnBlock = ^(UIButton *btn) {
        typeof(weakSelf) strongSelf = weakSelf;
        //弹出日历View
        strongSelf.calendarView.hidden ? [strongSelf showCalendar] : [strongSelf hiddenCalendar];
    };
    [self.dateFilterView addSubview:self.placeholderButton];
    
    //开启日期筛选之后显示的View
    self.dateFilterAbovedView = [[UIView alloc] init];
    self.dateFilterAbovedView.backgroundColor = [UIColor whiteColor];
    self.dateFilterAbovedView.layer.borderWidth = FTBDLayerBorderWidth;
    
    //日期过滤按钮，用来显示当前选中的日期文本，响应点击事件，传递给dateFilterArrowButton
    self.dateFilterButton = [[UIButton alloc] init];
    [self.dateFilterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.dateFilterButton addTarget:self action:@selector(dateFilterBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.dateFilterButton addTarget:self action:@selector(dateFilterBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    //日期过滤按钮，显示一个箭头，表明是展开日历还是隐藏日历
    self.dateFilterArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceDownArrowNormal] forState:UIControlStateNormal];
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceDownArrowHighlight] forState:UIControlStateHighlighted];
    [self.dateFilterArrowButton addTarget:self action:@selector(dateFilterBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.dateFilterAbovedView addSubview:self.dateFilterArrowButton];
    [self.dateFilterAbovedView addSubview:self.dateFilterButton];
    [self.view addSubview:self.dateFilterAbovedView];
    self.dateFilterAbovedView.hidden = YES;
    
    //初始化Calendar View
    self.calendarView = [[FTCalendarView alloc] init];
    self.calendarView.hidden = YES;
    self.calendarView.delegate = self;
    [self.view addSubview:self.calendarView];
    
    //初始化Table view
    self.newsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.newsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.newsTableView.dataSource = self;
    self.newsTableView.delegate = self;
    [self.newsTableView registerClass:[FTBDNewsTableViewCell class] forCellReuseIdentifier:FTBDNewsTableViewCellIdentifer];
    [self.view addSubview:self.newsTableView];
    
    //当过滤日期后没有当天的新闻后，显示该label用于提示
    self.noNewsMessageLabel = [[UILabel alloc] init];
    self.noNewsMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.noNewsMessageLabel.text = FTBDNoNewsMessage;
    self.noNewsMessageLabel.hidden = YES;
    [self.view addSubview:self.noNewsMessageLabel];
    
    //菊花
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.color = [UIColor grayColor];
    [self.view addSubview:self.indicatorView];
    
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
    _recursion = 0;
}


#pragma mark - private method

//调用NewsManager方法异步拉取新闻，通过协议方法notifyData接收返回消息
//cache表示是否从本地拉取
- (void)searchNews:(NSString *)keyword date:(NSDate *)date
{
    if ([keyword isEqualToString:@""]) {
        return;
    }
    if (_recursion > 0) {
        [_newsManager getBaiduNews:keyword date:date];
    }
    NSLog(@"FTBDNewsViewController->searchNews: 准备拉取新闻，keyword: %@", keyword);
    [_newsManager pullBaiduNews:keyword date:date];
}

- (void)hideKeyboard
{
    [self.searchTextField resignFirstResponder];
}

//弹出日历
- (void)showCalendar
{
    self.calendarView.hidden = NO;
    [self.view bringSubviewToFront:self.calendarView];
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceUpArrowNormal] forState:UIControlStateNormal];
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceUpArrowHighlight] forState:UIControlStateHighlighted];
    
    [self hideKeyboard];//显示日历应隐藏键盘
}

//隐藏日历
- (void)hiddenCalendar
{
    self.calendarView.hidden = YES;
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceDownArrowNormal] forState:UIControlStateNormal];
    [self.dateFilterArrowButton setImage:[UIImage imageNamed:FTResourceDownArrowHighlight] forState:UIControlStateHighlighted];
}

//更新Keyword，将tableview拉回顶部，同时拉取数据
- (void)refreshKeywordAndNews
{
//    [self resetFilter];//刷新新闻不应该重置日期过滤
    //但是应该隐藏日历
    [self hiddenCalendar];
    [self.newsTableView setContentOffset:CGPointZero animated:YES];
    //启动菊花
    [self.indicatorView startAnimating];
    
    NSString *newKeyword = self.searchTextField.text;

    //如果和当前显示的keyword不一样，则先显示缓存数据
    if (![_currentKeyword isEqualToString:newKeyword] && [_newsManager checkLocal:newKeyword]) {
        _recursion++;
    }
    _currentKeyword = self.searchTextField.text;
    NSLog(@"FTBDNewsViewController->refreshKeywordAndNews: 输入的搜索关键字 = %@", _currentKeyword);
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
    [self hideKeyboard];
    [self refreshKeywordAndNews];
}

//dateFilterButton按下事件，用于通知dateFilterArrowButton事件，主要是为了显示箭头被按下的动画效果
- (void)dateFilterBtnTouchDown:(UIButton *)sender
{
    self.dateFilterArrowButton.highlighted = YES;
}

//dateFilterButtons松开事件
- (void)dateFilterBtnTouchUpInside:(UIButton *)sender
{
    if (sender == self.dateFilterArrowButton) {//真实的时间过滤器显示日历的button事件响应
        if (self.calendarView.hidden) {
            [self showCalendar];
        } else {
            [self hiddenCalendar];
        }
    } else if (sender == self.dateFilterButton) {//发送消息给dateFilterArrowButton
        self.dateFilterArrowButton.highlighted = NO;
        [self.dateFilterArrowButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

//最底层view触摸响应
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hideKeyboard];
}

#pragma mark - UITabelViewDelegate


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTBDNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FTBDNewsTableViewCellIdentifer];
    
    NSInteger index = indexPath.row;
    FTBDNewsData *data = [_currentNews objectAtIndex:index];
    if (!data) {
        return cell;
    }
    
    //获取对应的UIImage，先判断是否有ImageURL
    UIImage *image = nil;
    if (![data.imageUrls isEqual:[NSNull null]]) {
        image = [self.newsManager imageForId:data.newsId];
        if (!image) {
//            NSLog(@"FTBDNewsViewController->cellForRowAtIndexPath->RequestImage: 请求图片, imageUrls: %@", [data.imageUrls firstObject]);
            [self.newsManager pullNewsImage:data cellId:index];
        }
    }
    
    [cell updateImageView:image title:data.title time:data.timeStr frame:CGRectMake(0, index * FTBDTabelViewCellHeight, CGRectGetWidth([UIScreen mainScreen].bounds), FTBDTabelViewCellHeight) readed:data.readed];
    
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
    [self.searchTextField resignFirstResponder];
    NSInteger index = indexPath.row;
    if (index < 0) {
        NSLog(@"FTBDNewsViewController->didSelectRowAtIndexPath->点击了第%ld行，行数竟然是负数？", indexPath.row);
        return;
    }
    FTBDNewsData *data = [_currentNews objectAtIndex:index];
    if (!data) {
        NSLog(@"FTBDNewsViewController->didSelectRowAtIndexPath->data为空");
        return;
    }
//    NSLog(@"FTBDNewsViewController->didSelectRowAtIndexPath->data ImageURls：%@", data.imageUrls);
    //设置查看后更改row背景颜色
    data.readed = YES;
    [self.newsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    NSString *url = data.url;
    FTBDNewsDetailsController *controller = [[FTBDNewsDetailsController alloc] init];
    [controller setupURL:url title:data.posterScreenName];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

//textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    [self refreshKeywordAndNews];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hiddenCalendar];
}

#pragma mark - FTBDNewsDelegate

//通知新闻拉取结果
- (void)notifyData:(NSArray *)news keyword:(NSString *)keyword
{
    if (![keyword isEqualToString:_currentKeyword]) {
        NSLog(@"FTBDNewsViewController->notifyData->keyword不匹配，不显示通知的新闻, 当前keyword：%@， 传入的keyword：%@", _currentKeyword, keyword);
        return;
    }
    //获取当前textField的
    _currentNews = news;
    __weak FTBDNewsViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //停止菊花
        if (strongSelf->_recursion > 0) {
            strongSelf->_recursion--;
        } else if (strongSelf->_recursion == 0) {
            [weakSelf.indicatorView stopAnimating];
        }
        
        if (!news || news.count == 0) {
            [weakSelf.view bringSubviewToFront:self.noNewsMessageLabel];
            weakSelf.noNewsMessageLabel.hidden = NO;
        } else {
            weakSelf.noNewsMessageLabel.hidden = YES;
        }
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
- (void)calendarView:(FTCalendarView *)calendarView doneWithDate:(NSDate *)date
{
    [self hiddenCalendar];
    NSLog(@"FTBDNewsViewController->doneWithDate: date: %@", [FTCalendarHelper stringOfDate:date]);
    [self updateDateFilter:date];
}

//日历中点击确认，隐藏日历，处理传回的一段日期
- (void)calendarView:(FTCalendarView *)calendarView doneWithDates:(NSDate *)from to:(NSDate *)to
{
    
}

#pragma mark - date filter

- (void)updateDateFilter:(NSDate *)date
{
    if (!date) {//不过滤日期
        [self resetFilter];
    } else {
        [self beginFilter:date];
    }
    [self.newsManager requireNews:_currentKeyword date:date];
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

#pragma mark - Tools

//计算状态栏加上导航栏的高度
- (CGFloat)calculateMainViewHeightOffset
{
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navRect = self.navigationController.navigationBar.frame;
    return statusRect.size.height + navRect.size.height;
}



@end
