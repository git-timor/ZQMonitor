//
//  ContactController_password_ap.m
//  Yoosee
//
//  Created by wutong on 15/10/15.
//  Copyright © 2015年 guojunyi. All rights reserved.
//

#import "ContactController_password_ap.h"
#import "TopBar.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "FListManager.h"
#import "MainController.h"
#import "Toast+UIView.h"
#import "ContactDAO.h"//多出的
#import "UDManager.h"
#import "LoginResult.h"
#import "Utils.h"//缺少的
#import "RecommendInfo.h"//缺少的
#import "RecommendInfoDAO.h"//缺少的

@interface ContactController_password_ap ()

@end

@implementation ContactController_password_ap

-(void)dealloc{
    [self.contactPasswordField release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //write code here...
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];//password strength
    
    /*
     *移除对键盘将要显示、收起的监听
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController_ap;
    [mainController setBottomBarHidden:YES];
    
    /*
     *设置通知监听者，监听键盘的显示、收起通知
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initComponent];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:YES];//不同
    //    [topBar setRightButtonText:NSLocalizedString(@"save", nil)];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"ap_mode_set_password", nil)];
    
    [self.view addSubview:topBar];
    [topBar release];
    
    //save
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake((self.view.frame.size.width-300)/2, self.view.frame.size.height-50, 300, 34)];
    UIImage *bottomButton1Image = [UIImage imageNamed:@"bg_blue_button"];
    UIImage *bottomButton1Image_p = [UIImage imageNamed:@"bg_blue_button_p"];
    bottomButton1Image = [bottomButton1Image stretchableImageWithLeftCapWidth:bottomButton1Image.size.width*0.5 topCapHeight:bottomButton1Image.size.height*0.5];
    bottomButton1Image_p = [bottomButton1Image_p stretchableImageWithLeftCapWidth:bottomButton1Image_p.size.width*0.5 topCapHeight:bottomButton1Image_p.size.height*0.5];
    [saveButton setBackgroundImage:bottomButton1Image forState:UIControlStateNormal];
    [saveButton setBackgroundImage:bottomButton1Image_p forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:NSLocalizedString(@"control", nil) forState:UIControlStateNormal];
    [self.view addSubview:saveButton];
    
    [self.view setBackgroundColor:XBgColor];
    
    //device 3cid
    NSString* contactid = [NSString stringWithFormat:@"%d", [[AppDelegate sharedDefault]dwApContactID]];
    UILabel *lableID = [[UILabel alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+80, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    lableID.text = [NSString stringWithFormat:@"%@:  %@", NSLocalizedString(@"ap_device_id", nil), contactid];
    lableID.textAlignment = NSTextAlignmentLeft;
    lableID.textColor = XBlack;
    lableID.backgroundColor = XBGAlpha;
    [self.view addSubview:lableID];
    [lableID release];
    
    //设备密码
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 80+NAVIGATION_BAR_HEIGHT+20*2+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field2.layer.borderWidth = 1;
        field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field2.layer.cornerRadius = 5.0;
    }
    field2.textAlignment = NSTextAlignmentLeft;
    field2.placeholder = NSLocalizedString(@"ap_password_length_tip", nil);
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field2.secureTextEntry = YES;
    field2.tag = 12;//password strength
    field2.delegate = self;//password strength
    [self.view addSubview:field2];
    self.contactPasswordField = field2;
    [field2 release];
    
    UILabel* lableTip = [[UILabel alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, self.contactPasswordField.frame.origin.y+TEXT_FIELD_HEIGHT+10, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, 100)];
    lableTip.lineBreakMode = NSLineBreakByWordWrapping; //自动折行设置
    lableTip.numberOfLines = 0;    lableTip.text = NSLocalizedString(@"ap_reconnect_wifi_tip", nil);
    lableTip.textAlignment = NSTextAlignmentLeft;
    lableTip.textColor = [UIColor redColor];
    lableTip.backgroundColor = XBGAlpha;
    lableTip.font = [UIFont systemFontOfSize: 12.0];
    [self.view addSubview:lableTip];
    [lableTip release];
    
}

#pragma mark - 监听键盘
#pragma mark 键盘将要显示时，调用
-(void)onKeyBoardWillShow:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    //keyBoard frame
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    DLog(@"%f",rect.size.height);
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGFloat offset1 = self.view.frame.size.height - self.contactPasswordField.frame.origin.y - self.contactPasswordField.frame.size.height;
                        
                        CGFloat finalOffset;
                        if(offset1-rect.size.height<0){
                            finalOffset = rect.size.height-offset1+10;
                        }else {
                            if(offset1-rect.size.height>=10){
                                finalOffset = 0;
                            }else{
                                finalOffset = 10-(offset1-rect.size.height);
                            }
                        }
                        self.view.transform = CGAffineTransformMakeTranslation(0, -finalOffset);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark 键盘将要收起时，调用
-(void)onKeyBoardWillHide:(NSNotification*)notification{
    DLog(@"onKeyBoardWillHide");
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onSavePress{
    NSString *password = self.contactPasswordField.text;
    if(password.length>16 || password.length<8){
        [self.view makeToast:NSLocalizedString(@"ap_password_length_tip", nil)];
        return;
    }

    if ([[ShakeManager sharedDefault]ApModeSetWifiPassword:password])
    {
        NSLog(@"set ok");
        UIAlertView *tip = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ap_setwifiok_tip", nil)
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"ok",nil)
                                            otherButtonTitles:nil];
        [tip show];
        [tip release];
    }
    else
    {
        NSLog(@"set failed");
    }
    
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
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
@end
