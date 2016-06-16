//
//  DynamicRadiosCell.m
//  Yoosee
//
//  Created by Nyshnukdny on 15-12-3.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "DynamicRadiosCell.h"
#import "Constants.h"

@implementation DynamicRadiosCell

-(void)dealloc{
    [self.radioView release];
    [self.radioTexts release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#define LEFT_ICON_WIDTH_HEIGHT 24
-(void)layoutSubviews{
    [super layoutSubviews];
    ////
    CGFloat cellWidth = self.backgroundView.frame.size.width;
    CGFloat cellHeight = self.backgroundView.frame.size.height;
    
    //防止cell重利用引起的问题，所以在此作一个remove操作
    if (self.radioView) {
        [self.radioView removeFromSuperview];
    }
    
    UIView *radioView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 0.0, cellWidth-20*2, cellHeight)];
    [self.contentView addSubview:radioView];
    self.radioView = radioView;
    [radioView release];
    
    int count = self.radioTexts.count;
    CGFloat space = (cellHeight-LEFT_ICON_WIDTH_HEIGHT*count)/(count+1);
    for (int i=0; i<count; i++) {
       UIButton *radioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        radioBtn.frame = CGRectMake(10, (i+1)*space+LEFT_ICON_WIDTH_HEIGHT*i, LEFT_ICON_WIDTH_HEIGHT, LEFT_ICON_WIDTH_HEIGHT);
        radioBtn.tag = [self.radioTexts[i] intValue];
        [radioBtn setImage:[UIImage imageNamed:@"ic_radio_button.png"] forState:UIControlStateNormal];
        [radioBtn setImage:[UIImage imageNamed:@"ic_radio_button_p.png"] forState:UIControlStateSelected];
        if(self.selectedIndex==[self.radioTexts[i] intValue]){
            [radioBtn setSelected:YES];
        }else{
            [radioBtn setSelected:NO];
        }
        [radioBtn addTarget:self action:@selector(btnClickToSetDeviceLanguage:) forControlEvents:UIControlEventTouchUpInside];
        [self.radioView addSubview:radioBtn];
        
        UILabel *radioLabel = [[UILabel alloc] initWithFrame:CGRectMake(radioBtn.frame.origin.x+LEFT_ICON_WIDTH_HEIGHT+20.0, (i+1)*space+LEFT_ICON_WIDTH_HEIGHT*i, cellWidth-10-LEFT_ICON_WIDTH_HEIGHT-20.0, LEFT_ICON_WIDTH_HEIGHT)];
        radioLabel.backgroundColor = XBGAlpha;
        radioLabel.text = [self deviceLanguageName:self.radioTexts[i]];
        radioLabel.font = XFontBold_14;
        radioLabel.textColor = XBlack;
        [self.radioView addSubview:radioLabel];
        [radioLabel release];
    }
    
}

#pragma mark - 选择语言类型
-(void)btnClickToSetDeviceLanguage:(UIButton *)button{
    //去掉所有语言的选中状态
    for (id obj in self.radioView.subviews) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *radioBtn = (UIButton *)obj;
            radioBtn.selected = NO;
        }
    }
    
    switch(button.tag){
        case LANG_EN:
        {
            button.selected = YES;
        }
            break;
        case LANG_CHS:
        {
            button.selected = YES;
        }
            break;
        case LANG_JP:
        {
            button.selected = YES;
        }
            break;
        case LANG_PT:
        {
            button.selected = YES;
        }
            break;
        case LANG_SP:
        {
            button.selected = YES;
        }
            break;
        case LANG_CF:
        {
            button.selected = YES;
        }
            break;
        case LANG_FR:
        {
            button.selected = YES;
        }
            break;
        case LANG_RU:
        {
            button.selected = YES;
        }
            break;
    }
    
    if(self.delegate){
        [self.delegate DynamicRadiosCellSwitchLanguage:(int)button.tag];
    }
}

#pragma mark - 设备支持的语言
-(NSString *)deviceLanguageName:(NSNumber *)supportLanguage{
    NSString *deviceLanguageName = @"";
    switch(supportLanguage.intValue){
        case 0:
        {
            deviceLanguageName = NSLocalizedString(@"push_language_english", nil);
        }
            break;
        case 1:
        {
            deviceLanguageName = NSLocalizedString(@"push_language_simplified", nil);
        }
            break;
        case 2:
        {
            deviceLanguageName = NSLocalizedString(@"push_language_japanese", nil);
        }
            break;
        case 3:
        {
            deviceLanguageName = NSLocalizedString(@"push_language_portuguese", nil);
        }
            break;
        case 4:
        {
            deviceLanguageName = NSLocalizedString(@"push_language_spanish", nil);
        }
            break;
        case 5:
        {
            deviceLanguageName = NSLocalizedString(@"push_language_traditional", nil);
        }
            break;
        case 6:
        {
            deviceLanguageName = NSLocalizedString(@"push_language_french", nil);
        }
            break;
        case 7:
        {
            deviceLanguageName = NSLocalizedString(@"push_language_russian", nil);
        }
            break;
    }
    return deviceLanguageName;
}

@end
