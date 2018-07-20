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
static const CGFloat FTBDImageViewWidth = 80;

static const CGFloat FTBDTitleLabelHeight = 40;
static const CGFloat FTBDTitleLabelWitdhMargin = 10;
static const CGFloat FTBDTitleLabelHeightMargin = 10;

static const CGFloat FTBDBottomLineWidth = 0.5f;


@interface FTBDNewsTableViewCell ()
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    
    UIView *_maskView;
    UILabel *_bottomLine;
}

@end

@implementation FTBDNewsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    _imageView = [[UIImageView alloc] init];
//    _imageView.layer.borderWidth = 1.0;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16];
//    _titleLabel.layer.borderWidth = 1.0;
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:14];
//    _timeLabel.layer.borderWidth = 1.0;
    
    _maskView = [[UIView alloc] init];
    _maskView.layer.borderWidth = 1.0;
    [_maskView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressNews:)];
    [_maskView addGestureRecognizer:tapGesture];
    
    _bottomLine = [[UILabel alloc] init];
    _bottomLine.text = @"";
    _bottomLine.layer.borderWidth = FTBDBottomLineWidth;
    
    [self addSubview:_imageView];
    [self addSubview:_titleLabel];
    [self addSubview:_timeLabel];
//    [self addSubview:_maskView];
    [self addSubview:_bottomLine];
}

- (void)layoutSubviews
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat widthOffset = FTBDImageViewWidthMargin;
    CGFloat labelWidth = 0;

    [_imageView setFrame:CGRectMake(widthOffset, FTBDImageViewHeightMargin, FTBDImageViewWidth, height - FTBDImageViewWidthMargin * 2)];

    widthOffset += FTBDImageViewWidth + FTBDTitleLabelWitdhMargin;
    labelWidth = width - widthOffset - FTBDTitleLabelWitdhMargin;
    
    [_titleLabel setFrame:CGRectMake(widthOffset, FTBDTitleLabelHeightMargin, labelWidth, FTBDTitleLabelHeight)];
    [_timeLabel setFrame:CGRectMake(widthOffset, FTBDTitleLabelHeightMargin + FTBDTitleLabelHeight, labelWidth, FTBDTitleLabelHeight)];
    [_maskView setFrame:CGRectMake(0, 0, width, height)];
    
    [_bottomLine setFrame:CGRectMake(0, height - FTBDBottomLineWidth, width, 1.0)];//line的高度向上挪1，空出1.0的高度
//    NSLog(@"更新子Views的Layout，width = %f, height = %f", width, height);
}

- (void)updateImageView:(UIImage *)image title:(NSString *)title time:(NSString *)time frame:(CGRect)frame
{
    [self setFrame:frame];
    if(image == nil) {
        _imageView.image = [UIImage imageNamed:@"LoadFail"];
    } else {
        _imageView.image = image;
    }
    _titleLabel.text = title;
    _timeLabel.text = time;
//    [self updateSubViews];
}

#pragma mark - Callback

- (void)pressNews:(UITapGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"进入新闻页面, %@", sender.view);
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
