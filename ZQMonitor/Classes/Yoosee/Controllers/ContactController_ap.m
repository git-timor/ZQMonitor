//
//  ContactController_ap.m
//  Yoosee
//
//  Created by wutong on 15/9/30.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
#import "ContactController_ap.h"
#import "P2PPlaybackController.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "MainSettingController.h"
#import "ContactController_password_ap.h"
#import "TopBar.h"
#import "Constants.h"
#import "Utils.h"
#import "ContactDAO.h"
#import "Toast+UIView.h"
#import "YProgressView.h"

#define CONTACT_ITEM_HEIGHT_AP (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 300:180)
#define HEADER_ICON_VIEW_HEIGHT_WIDTH 70
#define EMPTY_LABEL_WIDTH 260
#define EMPTY_LABEL_HEIGHT 50

enum
{
    ap_btn_tag_preview = 100,
    ap_btn_tag_playback,
    ap_btn_tag_setting,
    ap_btn_tag_defence,
    ap_btn_tag_edit,
    ap_btn_tag_quit
};

@interface ContactController_ap ()
{
    Contact* _contacet;
    UIImageView *_buttonImageView;
    
    UIImageView *_imageView;
    YProgressView* _progressView;
}

@end

@implementation ContactController_ap

-(void)dealloc
{
    if (_contacet) {
        [_contacet release];
        _contacet = nil;
    }
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = XBgColor;
    [self initComponent];
    
    NSString* contactid = [NSString stringWithFormat:@"%d", [[AppDelegate sharedDefault]dwApContactID]];

    _contacet = [[Contact alloc]init];
    _contacet.contactId = ap_p2p_id;
    _contacet.contactName = contactid;
    _contacet.contactPassword = ap_p2p_password;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ap_enter_message:) name:AP_ENTER_FORCEGROUND_MESSAGE object:nil];
    
    [self startGetDenfenceStatus];
}

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController_ap;
    [mainController setBottomBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateHeadPicture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)initComponent
{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    NSString* contactid = [NSString stringWithFormat:@"%d", [[AppDelegate sharedDefault] dwApContactID]];
    [topBar setTitle:[NSString stringWithFormat:@"%@   %@", NSLocalizedString(@"ap_mode_text", nil), contactid]];
    [self.view addSubview:topBar];
    [topBar release];
    
    UIButton *monitorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [monitorButton addTarget:self action:@selector(onBtnAp:) forControlEvents:UIControlEventTouchUpInside];
    monitorButton.tag = ap_btn_tag_preview;
    monitorButton.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, CONTACT_ITEM_HEIGHT_AP);
    UIImageView *buttonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, monitorButton.frame.size.width, monitorButton.frame.size.height)];
    _buttonImageView = buttonImageView;
    
    NSString *filePath = [Utils getHeaderFilePathWithId:contactid];
    UIImage *headerViewImg = [UIImage imageWithContentsOfFile:filePath];
    if(headerViewImg==nil){
        buttonImageView.image = [UIImage imageNamed:@"ic_header_ap.png"];
    }
    else
    {
        buttonImageView.image = headerViewImg;
    }

    
    
    UIImageView *addButtonView = [[UIImageView alloc] initWithFrame:CGRectMake((monitorButton.frame.size.width-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, (monitorButton.frame.size.height-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, HEADER_ICON_VIEW_HEIGHT_WIDTH, HEADER_ICON_VIEW_HEIGHT_WIDTH)];
    addButtonView.image = [UIImage imageNamed:@"ic_header_play_ap.png"];
    
    [monitorButton addSubview:buttonImageView];
    [monitorButton addSubview:addButtonView];
    [addButtonView release];
    [buttonImageView release];
    
    [self.view addSubview:monitorButton];
    [monitorButton release];
    
    CGFloat intervalx = 25;
    CGFloat widthBtnS = (width-intervalx*2-10)/2;
    CGFloat widthBtnL = width-intervalx*2;
    CGRect arrayRect[5] =
    {
        CGRectMake(intervalx, CONTACT_ITEM_HEIGHT_AP+80, widthBtnS, 40),
        CGRectMake(intervalx+widthBtnS+10, CONTACT_ITEM_HEIGHT_AP+80, widthBtnS, 40),
        CGRectMake(intervalx, CONTACT_ITEM_HEIGHT_AP+140, widthBtnS, 40),
        CGRectMake(intervalx+widthBtnS+10, CONTACT_ITEM_HEIGHT_AP+140, widthBtnS, 40),
        CGRectMake(intervalx, CONTACT_ITEM_HEIGHT_AP+200, widthBtnL, 40),
    };
    
    NSString* arrayText[5] =
    {
        NSLocalizedString(@"ap_mode_btn_playback", nil),
        NSLocalizedString(@"ap_mode_btn_setting", nil),
        @"",//@"布防",
        NSLocalizedString(@"ap_mode_btn_password", nil),
        NSLocalizedString(@"ap_mode_btn_quit", nil),
    };
    
    UIImage* arrayImgage[5] =
    {
        [UIImage imageNamed:@"ap_playback_p.png"],
        [UIImage imageNamed:@"ap_settings_p.png"],
        nil,
        [UIImage imageNamed:@"ap_setwifi_p.png"],
        nil
    };
    
    for (int i=0; i<5; i++) {
        UIButton* btn = [[UIButton alloc]initWithFrame:arrayRect[i]];
        btn.tag = ap_btn_tag_playback+i;
        if (i==0 || i == 1 || i ==3)
        {
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [btn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop]; //设置对齐后可以比较方便的设置偏移位置

            [btn setImage:arrayImgage[i] forState:UIControlStateNormal];
        }
        [btn setTitle:arrayText[i] forState:UIControlStateNormal];
        [btn.titleLabel setFont:XFontBold_16];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [btn setBackgroundImage:[UIImage imageNamed:@"bg_button_ap.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"bg_button_ap_p.png"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(onBtnAp:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [btn release];
        
        if (i == 2) {
            int width = arrayRect[i].size.width;
            int height = arrayRect[i].size.height;
            int len = height - 2*8;
            CGRect rect = CGRectMake((width-len)/2, 8, len, len);

            
            _imageView = [[UIImageView alloc] initWithFrame:rect];
            [btn addSubview:_imageView];
            [_imageView release];
            
            _progressView = [[YProgressView alloc] initWithFrame:rect];
            _progressView.backgroundView.image = [UIImage imageNamed:@"ic_progress_arrow.png"];
            [btn addSubview:_progressView];
            [_progressView release];

        }
        else if (i==0 || i==1 || i ==3)
        {
            int imageWidth = 10, imageHeight = 20;

            CGSize labelSize = [arrayText[i] sizeWithFont:btn.titleLabel.font];
            CGFloat intervalImageY = (arrayRect[i].size.height - imageHeight)/2;
            CGFloat intervalTextY = (arrayRect[i].size.height - labelSize.height)/2;
            CGFloat contentWidth = imageWidth+labelSize.width+10;
            CGFloat intervalImageX = (width/2 - contentWidth)/2;
            //相对于btn.frame的坐标
            CGFloat intervalTextX = intervalImageX + imageWidth - btn.titleLabel.frame.origin.x;
            btn.titleEdgeInsets = UIEdgeInsetsMake(intervalTextY, intervalTextX, 0, 0);
            btn.imageEdgeInsets = UIEdgeInsetsMake(intervalImageY, intervalImageX, intervalImageY, width/2-intervalImageX-imageWidth);
       }
    }
}

-(void)onBtnAp:(id)sender
{
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case ap_btn_tag_preview:
        {
            MainController *mainController_ap = [AppDelegate sharedDefault].mainController_ap;
            [mainController_ap setUpCallWithId:ap_p2p_id password:ap_p2p_password callType:P2PCALL_TYPE_MONITOR];
        }
            break;
            
        case ap_btn_tag_playback:
        {
            P2PPlaybackController *playbackController = [[P2PPlaybackController alloc] init];
            playbackController.contact = _contacet;
            [self.navigationController pushViewController:playbackController animated:YES];
            [playbackController release];

        }
            break;
            
        case ap_btn_tag_setting:
        {
            MainSettingController *mainSettingController = [[MainSettingController alloc] init];
            mainSettingController.contact = _contacet;
            [self.navigationController pushViewController:mainSettingController animated:YES];
            [mainSettingController release];
        }
            break;
            
        case ap_btn_tag_defence:
        {
            if ([[AppDelegate sharedDefault]dwApDefenceStatus] == DEFENCE_STATE_OFF) {
                [self startSetDenfenceStatus:DEFENCE_STATE_ON];
            }
            else if ([[AppDelegate sharedDefault]dwApDefenceStatus] == DEFENCE_STATE_ON)
            {
                [self startSetDenfenceStatus:DEFENCE_STATE_OFF];
            }
            else
            {
                [self startGetDenfenceStatus];
            }
        }
            break;
            
        case ap_btn_tag_edit:
        {
            ContactController_password_ap *addContactNextController = [[ContactController_password_ap alloc] init];
            [self.navigationController pushViewController:addContactNextController animated:YES];
            [addContactNextController release];
        }
            break;

        case ap_btn_tag_quit:
        {
            UIAlertView *unBindEmailAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ap_mode_quit", nil)
                                                                       message:@""
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                             otherButtonTitles:nil,nil];
            [unBindEmailAlert show];
            [unBindEmailAlert release];

        }
            break;

        default:
            break;
    }
}

#pragma mark -
-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    return (interface == UIInterfaceOrientationPortrait );
}

#ifdef IOS6

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

-(void)updateHeadPicture
{
    NSString* contactid = [NSString stringWithFormat:@"%d", [[AppDelegate sharedDefault]dwApContactID]];
    NSString *filePath = [Utils getHeaderFilePathWithId:contactid];
    UIImage *headerViewImg = [UIImage imageWithContentsOfFile:filePath];
    if(headerViewImg!=nil && _buttonImageView){
        _buttonImageView.image = headerViewImg;
    }
}

/*
 该函数4种情况会被调用:
 1、程序启动时-viewdidload调用startGetDenfenceStatus函数
 2、程序进入时 a.ap->ap 发AP_ENTER_FORCEGROUND_MESSAGE消息
             b.id->ap a1.需要创建新的控制器,viewdidload调用startGetDenfenceStatus函数
                      b1.不需要，发AP_ENTER_FORCEGROUND_MESSAGE消息
*/
-(void)startGetDenfenceStatus
{
    [_imageView setHidden:YES];
    [_progressView setHidden:NO];
    [_progressView start];
    [[AppDelegate sharedDefault] setDwApDefenceStatus:DEFENCE_STATE_LOADING];
    [[P2PClient sharedClient]getDefenceState:ap_p2p_id password:ap_p2p_password];
}

-(void)startSetDenfenceStatus:(NSInteger)status
{
    [_imageView setHidden:YES];
    [_progressView setHidden:NO];
    [_progressView start];
    [[P2PClient sharedClient]setRemoteDefenceWithId:ap_p2p_id password:ap_p2p_password state:status];
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    if (key != RET_GET_NPCSETTINGS_REMOTE_DEFENCE &&
        key != RET_SET_NPCSETTINGS_REMOTE_DEFENCE) {
        return;
    }
    
//    NSString *contactId = [parameter valueForKey:@"contactId"];
//    if ([contactId intValue] != 1)
//        return;
    
    int result = [[parameter valueForKey:@"result"] intValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(result==2)  //网络异常
        {
            _imageView.image = [UIImage imageNamed:@"ic_defence_warning.png"];
            [_progressView stop];
            [_progressView setHidden:YES];
            [[AppDelegate sharedDefault] setDwApDefenceStatus:DEFENCE_STATE_WARNING_NET];
            [self.view makeToast:NSLocalizedString(@"net_exception", nil)];
        }
    });
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    
    if (key != RET_GET_NPCSETTINGS_REMOTE_DEFENCE &&
        key != RET_SET_NPCSETTINGS_REMOTE_DEFENCE) {
        return;
    }
    
//    NSString *contactId = [parameter valueForKey:@"contactId"];
//    if ([contactId intValue] != 1)
//        return;
    
    switch(key){
        case RET_GET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_imageView setHidden:NO];
                [_progressView stop];
                [_progressView setHidden:YES];

                NSInteger state = [[parameter valueForKey:@"state"] intValue];
                if(state==SETTING_VALUE_REMOTE_DEFENCE_STATE_ON)
                {
                    [[AppDelegate sharedDefault] setDwApDefenceStatus:DEFENCE_STATE_ON];
                    _imageView.image = [UIImage imageNamed:@"ic_defence_on.png"];
                }
                else
                {
                    [[AppDelegate sharedDefault] setDwApDefenceStatus:DEFENCE_STATE_OFF];
                    _imageView.image = [UIImage imageNamed:@"ic_defence_off.png"];
                }
            });
        }
            break;
            
        case RET_SET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_imageView setHidden:NO];
                [_progressView stop];
                [_progressView setHidden:YES];

                NSInteger state = [[parameter valueForKey:@"state"] intValue];
                if(state==SETTING_VALUE_REMOTE_DEFENCE_STATE_ON)
                {
                    [[AppDelegate sharedDefault] setDwApDefenceStatus:DEFENCE_STATE_ON];
                    _imageView.image = [UIImage imageNamed:@"ic_defence_on.png"];
                }
                else
                {
                    [[AppDelegate sharedDefault] setDwApDefenceStatus:DEFENCE_STATE_OFF];
                    _imageView.image = [UIImage imageNamed:@"ic_defence_off.png"];
                }
            });
        }
            break;
    }
}

-(void)ap_enter_message:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startGetDenfenceStatus];
    });
}
@end
