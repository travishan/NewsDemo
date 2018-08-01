//
//  FTCalendarButton.h
//  CollectionTest
//
//  Created by wilsonhan on 2018/7/12.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 继承UIButton，声明一些通用的属性，如
 * 字体颜色设置
 * textAlignment设置
 * 回调Block的添加
 */

typedef void (^FTCalendarButtonBlock)(UIButton *);

@interface FTCalendarButton : UIButton

@property (strong, nonatomic) FTCalendarButtonBlock btnBlock;

@end
