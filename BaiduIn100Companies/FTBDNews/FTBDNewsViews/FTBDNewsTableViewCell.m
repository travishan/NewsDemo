//
//  FTBDNewsTableViewCell.m
//  BaiduIn100Companies
//
//  Created by wilsonhan on 2018/7/17.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import "FTBDNewsTableViewCell.h"

static const CGFloat FTBDImageViewWidthMargin = 10;
static const CGFloat FTBDImageViewHeightMargin = 10;
static const CGFloat FTBDImageViewWidth = 121;
static const CGFloat FTBDImageViewHeight = 81;

static const CGFloat FTBDTitleLabelHeight = 40;
static const CGFloat FTBDTitleLabelWitdhMargin = 10;
static const CGFloat FTBDTitleLabelHeightMargin = 10;

static const CGFloat FTBDBottomLineWidth = 0.5f;


@interface FTBDNewsTableViewCell ()
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    UILabel *_bottomLine;
}

@end

@implementation FTBDNewsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    _imageView = [[UIImageView alloc] init];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:14];
    
    _bottomLine = [[UILabel alloc] init];
    _bottomLine.text = @"";
    _bottomLine.layer.borderWidth = FTBDBottomLineWidth;
    
    [self addSubview:_imageView];
    [self addSubview:_titleLabel];
    [self addSubview:_timeLabel];
    [self addSubview:_bottomLine];
}

- (void)layoutSubviews
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat widthOffset = FTBDImageViewWidthMargin;//记录view横坐标的偏移量
    CGFloat labelWidth = 0;//计算label的宽度

//    [_imageView setFrame:CGRectMake(widthOffset, FTBDImageViewHeightMargin, FTBDImageViewWidth, height - FTBDImageViewWidthMargin * 2)];
    [_imageView setFrame:CGRectMake(widthOffset, FTBDImageViewHeightMargin, FTBDImageViewWidth, FTBDImageViewHeight)];
    
    widthOffset += FTBDImageViewWidth + FTBDTitleLabelWitdhMargin;//此时横坐标的偏移量在imageview的右边+一个margin的距离
    labelWidth = width - widthOffset - FTBDTitleLabelWitdhMargin;
    
    [_titleLabel setFrame:CGRectMake(widthOffset, FTBDTitleLabelHeightMargin, labelWidth, FTBDTitleLabelHeight)];
    [_timeLabel setFrame:CGRectMake(widthOffset, FTBDTitleLabelHeightMargin + FTBDTitleLabelHeight, labelWidth, FTBDTitleLabelHeight)];
    
    [_bottomLine setFrame:CGRectMake(0, height - FTBDBottomLineWidth, width, 1.0)];//line的高度向上挪1，空出1.0的高度
}

- (void)updateImageView:(UIImage *)image title:(NSString *)title time:(NSString *)time frame:(CGRect)frame readed:(BOOL)readed
{
    [self setFrame:frame];
    if (!image) {
        _imageView.image = [UIImage imageNamed:@"LoadFail"];
    } else {
        _imageView.image = image;
    }
    _titleLabel.text = title;
    _timeLabel.text = time;
    if (readed) {
        self.backgroundColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1.0];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - Callback

- (void)pressNews:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"进入新闻页面, %@", sender.view);
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
