//
//  CustomCell.h
//  Yoosee
//
//  Created by guojunyi on 14-3-29.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell

@property (strong,nonatomic) NSString *leftIcon;
@property (strong,nonatomic) NSString *rightIcon;
@property (strong,nonatomic) NSString *labelText;

@property (strong, nonatomic) UIImageView *leftIconView;
@property (strong, nonatomic) UIImageView *leftIconView_p;

@property (strong, nonatomic) UILabel *textLabelView;
@property (strong, nonatomic) UILabel *textLabelView_p;

@property (strong, nonatomic) UIImageView *rightIconView;
@property (strong, nonatomic) UIImageView *rightIconView_p;

@property (strong,nonatomic) NSString *newDeviceIcon;//设备检查更新
@property (strong, nonatomic) UIImageView *newDeviceIconView;//设备检查更新

@end
