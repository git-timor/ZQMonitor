//
//  ModifyVisitorPasswordController.h
//  Yoosee
//
//  Created by guojunyi on 14-9-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySettingController.h"
@class Contact;
@class MBProgressHUD;
@class TopBar;
@interface ModifyVisitorPasswordController : UIViewController
@property(strong, nonatomic) Contact *contact;
@property (nonatomic, strong) UITextField *field1;
@property (nonatomic, strong) TopBar *topBar;

@property (strong, nonatomic) SecuritySettingController *securitySettingController;

@property (strong, nonatomic) NSString *lastSetNewPassowrd;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (nonatomic, strong) UIButton *clearButton;

@end
