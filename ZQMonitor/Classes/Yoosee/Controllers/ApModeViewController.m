//
//  ApModeViewController.m
//  Yoosee
//
//  Created by wutong on 15/9/29.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "ApModeViewController.h"
#import "AppDelegate.h"
#import "TopBar.h"

@implementation ApModeViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initComponent];
}

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:YES];
}

-(void)initComponent{
    [self.view setBackgroundColor:XBgColor];

    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:YES];//不同
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"ap_mode_guard", nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    NSString* arrayText[4] =
    {
        NSLocalizedString(@"ap_mode_introduce01", nil),
        NSLocalizedString(@"ap_mode_introduce02", nil),
        NSLocalizedString(@"ap_mode_introduce03", nil),
        NSLocalizedString(@"ap_mode_introduce04", nil)
    };
    
    for (int i=0; i<4; i++) {
        UILabel* lableTip = [[UILabel alloc]initWithFrame:CGRectMake(15, 50+50*i+NAVIGATION_BAR_HEIGHT, rect.size.width-30, 100)];
        [lableTip setText:arrayText[i]];
        lableTip.lineBreakMode = NSLineBreakByWordWrapping; //自动折行设置
        lableTip.numberOfLines = 0;
        lableTip.font = XFontBold_16;
        lableTip.textAlignment = NSTextAlignmentLeft;
        lableTip.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lableTip];
        [lableTip release];

    }
 }

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
