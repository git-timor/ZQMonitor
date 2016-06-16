//
//  DynamicRadiosCell.h
//  Yoosee
//
//  Created by Nyshnukdny on 15-12-3.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

//设备支持的语言
enum{
    LANG_EN, // 0 默认 英文
    LANG_CHS, // 1 中文简体
    LANG_JP,// 2 日语
    LANG_PT, //3 葡萄牙
    LANG_SP, // 4 西班牙
    LANG_CF, // 5 中文繁体
    LANG_FR, // 6 法语
    LANG_RU, // 7 俄语
    
    
    MAX_LANG,
};

@protocol DynamicRadiosCellDelegate <NSObject>
@optional
-(void)DynamicRadiosCellSwitchLanguage:(int)selectedIndex;
@end

@interface DynamicRadiosCell : UITableViewCell

@property (strong, nonatomic) UIView *radioView;
@property (assign) int selectedIndex;
@property (strong, nonatomic) NSArray *radioTexts;

@property (assign) id<DynamicRadiosCellDelegate> delegate;

@end
