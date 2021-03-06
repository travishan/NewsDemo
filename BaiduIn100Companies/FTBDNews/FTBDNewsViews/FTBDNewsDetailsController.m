//
//  FTBDNewsDetailsController.m
//  BaiduIn100Companies
//
//  Created by wilsonhan on 2018/7/17.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTBDNewsDetailsController.h"

@interface FTBDNewsDetailsController () <UIWebViewDelegate>
{
    BOOL _isIndicating;
}
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) NSString *webUrl;

@end

@implementation FTBDNewsDetailsController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    
}

- (void)initUI
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.scalesPageToFit = YES;//自动对页面缩放以适应屏幕
    self.webView.delegate = self;
    
    NSURL *url = [NSURL URLWithString:_webUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [self.webView loadRequest:request];
    
    [self.view addSubview:self.webView];
    
    //指示器
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat x = CGRectGetWidth(self.view.frame) / 2;
    CGFloat y = CGRectGetHeight(self.view.frame) / 2;
    self.indicatorView.center = CGPointMake(x, y);
    [self.view addSubview:self.indicatorView];
    _isIndicating = NO;
}

- (void)setupURL:(NSString *)_url title:(NSString *)title
{
    self.webUrl = _url;
    self.navigationItem.title = title;
}


#pragma mark - UIWebViewDelegate


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error != nil && error.code == NSURLErrorNotConnectedToInternet) {
        [self stopIndicator];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"糟糕" message:@"网页加载失败的感觉！您的网络好像不太好" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    NSLog(@"FTBDNewsDetailsController->startIndicator->加载网页失败，原因: %@, code = %ld", error.localizedDescription, error.code);
}


#pragma mark - private method

- (void)startIndicator
{
    if (!_isIndicating) {
        NSLog(@"FTBDNewsDetailsController->startIndicator->开始转菊花");
        [self.indicatorView startAnimating];
        _isIndicating = YES;
    }
}

- (void)stopIndicator
{
    if (_isIndicating) {
        NSLog(@"FTBDNewsDetailsController->stopIndicator->停止转菊花");
        [self.indicatorView stopAnimating];
        _isIndicating = NO;
    }
}

@end
