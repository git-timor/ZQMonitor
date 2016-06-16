//
//  LanguageSettingController.m
//  Yoosee
//
//  Created by Nyshnukdny on 15-12-3.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "LanguageSettingController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "P2PEmailSettingCell.h"
#import "Toast+UIView.h"

@interface LanguageSettingController ()

@end

@implementation LanguageSettingController

-(void)dealloc{
    [self.tableView release];
    [self.contact release];
    [self.languageSupports release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    self.isLoadingDeviceSupportLanguage = YES;
    [[P2PClient sharedClient] getDeviceSupportedLanguageAndCurrentLanguageWithId:self.contact.contactId password:self.contact.contactPassword];
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_GET_DEVICE_LANGUAGE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            if (result == 1) {
                self.supportLanguageCount = [[parameter valueForKey:@"supportLanguageCount"] intValue];
                self.currentLanguage = [[parameter valueForKey:@"currentLanguage"] intValue];
                self.languageSupports = [parameter valueForKey:@"languageSupports"];
                
                self.isLoadingDeviceSupportLanguage = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
            break;
        case RET_SET_DEVICE_LANGUAGE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            if (result == 0) {
//                self.supportLanguageCount = [[parameter valueForKey:@"supportLanguageCount"] intValue];
//                self.currentLanguage = [[parameter valueForKey:@"currentLanguage"] intValue];
//                self.languageSupports = [parameter valueForKey:@"languageSupports"];
                [[P2PClient sharedClient] getDeviceSupportedLanguageAndCurrentLanguageWithId:self.contact.contactId password:self.contact.contactPassword];
            }
            self.isSettingDeviceCurLanguage = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
            break;
        case RET_DEVICE_NOT_SUPPORT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view makeToast:NSLocalizedString(@"device_not_support", nil)];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    usleep(800000);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self onBackPress];
                    });
                });
            });
        }
            break;
    }
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
        case ACK_RET_GET_DEVICE_LANGUAGE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend get npc settings");
                    [[P2PClient sharedClient] getDeviceSupportedLanguageAndCurrentLanguageWithId:self.contact.contactId password:self.contact.contactPassword];
                }
            });
        }
            break;
        case ACK_RET_SET_DEVICE_LANGUAGE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend get npc settings");
                    [[P2PClient sharedClient] setDeviceCurrentLanguageWithId:self.contact.contactId password:self.contact.contactPassword currentLanguage:self.lastSetLanguage];
                }
            });
        }
            break;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initComponent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initComponent{
    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"push_language",nil)];
    [self.navigationController setNavigationBarHidden:YES];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.isLoadingDeviceSupportLanguage){
        return 1;
    }else{
        return 2;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==1){
        return BAR_BUTTON_HEIGHT*self.supportLanguageCount;
    }else{
        return BAR_BUTTON_HEIGHT;
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PEmailSettingCell";
    static NSString *identifier2 = @"DynamicRadiosCell";
    
    UITableViewCell *cell = nil;
    
    int row = indexPath.row;
    UIImage *backImg;
    UIImage *backImg_p;
    
    if(row==0){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        if(cell==nil){
            cell = [[[DynamicRadiosCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }
    
    if(row==0){
        P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
        if(self.isLoadingDeviceSupportLanguage){
            backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
        }else{
            backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
        }
        [emailCell setLeftLabelText:NSLocalizedString(@"language_switching", nil)];
        [emailCell setLeftIconHidden:YES];
        [emailCell setLeftLabelHidden:NO];
        [emailCell setRightIconHidden:YES];
        [emailCell setRightLabelHidden:YES];
        if(self.isLoadingDeviceSupportLanguage || self.isSettingDeviceCurLanguage){
            [emailCell setProgressViewHidden:NO];
        }else{
            [emailCell setProgressViewHidden:YES];
        }
        
    }else{
        DynamicRadiosCell *dynamicRadiosCell = (DynamicRadiosCell*)cell;
        backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
        backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
        [dynamicRadiosCell setSelectedIndex:self.currentLanguage];
        [dynamicRadiosCell setRadioTexts:self.languageSupports];
        dynamicRadiosCell.delegate = self;
    }
    
    UIImageView *backImageView = [[UIImageView alloc] init];
    
    
    
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backImageView.image = backImg;
    [cell setBackgroundView:backImageView];
    [backImageView release];
    
    UIImageView *backImageView_p = [[UIImageView alloc] init];
    
    backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
    backImageView_p.image = backImg_p;
    [cell setSelectedBackgroundView:backImageView_p];
    [backImageView_p release];
    
    
    
    return cell;
}

#pragma mark - DynamicRadiosCellDelegate
-(void)DynamicRadiosCellSwitchLanguage:(int)selectedIndex{
    
    self.isSettingDeviceCurLanguage = YES;
    [self.tableView reloadData];
    
    self.lastSetLanguage = selectedIndex;
    [[P2PClient sharedClient] setDeviceCurrentLanguageWithId:self.contact.contactId password:self.contact.contactPassword currentLanguage:self.lastSetLanguage];
}

@end
