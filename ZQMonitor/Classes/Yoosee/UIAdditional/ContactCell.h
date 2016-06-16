//
//  ContactCell.h
//  Gviews
//
//  Created by guojunyi on 14-4-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "YProgressView.h"
@protocol OnClickDelegate
-(void)onClick:(NSInteger)position contact:(Contact*)contact;
//通话、回放、设置和修改按钮
-(void)ContactCellOnClickBottomBtn:(int)btnTag contact:(Contact*)contact;
@end

@class Contact;
@interface ContactCell : UITableViewCell
@property (strong, nonatomic) Contact *contact;

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIButton *headView;
@property (strong, nonatomic) UIImageView *typeView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *stateLabel;
@property (strong, nonatomic) UIButton *weakPwdButton;
@property (strong, nonatomic) UIButton *updateDeviceBtn;
@property (strong, nonatomic) UIButton *initDeviceButton;

@property (strong, nonatomic) UIButton *defenceStateView;
@property (strong, nonatomic) YProgressView *defenceProgressView;

@property (strong, nonatomic) UIImageView *messageCountView;

@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UIView *bottomView;
//设置之前，临时保存未按下时，按钮当前显示的图片；将用于松开按钮时，恢复
@property (strong, nonatomic) UIImage *btnNormalImg;

@property (strong, nonatomic) id<OnClickDelegate> delegate;
@property (nonatomic) NSInteger position;

@end
