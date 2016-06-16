//
//  LanguageSettingController.h
//  Yoosee
//
//  Created by Nyshnukdny on 15-12-3.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "DynamicRadiosCell.h"

@interface LanguageSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,DynamicRadiosCellDelegate>

@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;
@property(nonatomic) int supportLanguageCount;
@property(nonatomic) int currentLanguage;
@property(nonatomic) int lastSetLanguage;
@property (strong, nonatomic) NSArray *languageSupports;

@property(assign) BOOL isLoadingDeviceSupportLanguage;
@property(assign) BOOL isSettingDeviceCurLanguage;

@end
