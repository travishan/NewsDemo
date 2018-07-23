//
//  FTBDNewsTableViewCell.h
//  BaiduIn100Companies
//
//  Created by wilsonhan on 2018/7/17.
//  Copyright © 2018年 wilsonhan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTBDNewsTableViewCell : UITableViewCell

- (void)updateImageView:(UIImage *)image title:(NSString *)title time:(NSString *)time frame:(CGRect)frame readed:(BOOL)readed;

@end
