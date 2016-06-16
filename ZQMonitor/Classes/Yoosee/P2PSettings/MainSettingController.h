//
//  MainSettingController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;
@class  MBProgressHUD;
#define ALERT_TAG_UPDATE 1
@interface MainSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong, nonatomic) Contact *contact;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) UIView *progressMaskView;
@property (strong, nonatomic) UILabel *progressLabel;
@property(strong, nonatomic) UITableView *tableView;
//YES表示在当前界面，用户向设备发送了远程消息请求
@property (nonatomic) BOOL isSendRomoteMessageInCurrentInterface;//设备检查更新
@property (strong,nonatomic)NSTimer * timer;

@end
