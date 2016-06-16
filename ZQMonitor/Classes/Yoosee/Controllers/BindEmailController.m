//
//  BindEmailController.m
//  Yoosee
//
//  Created by guojunyi on 14-4-26.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "BindEmailController.h"
#import "MainController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "TopBar.h"
#import "NetManager.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "MBProgressHUD.h"
#import "Toast+UIView.h"
@interface BindEmailController ()

@end

@implementation BindEmailController

-(void)dealloc{
    [self.field1 release];
    [self.progressAlert release];
    [self.unbindButton release];
    [self.topBar release];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //write code here ...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.field1];
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    if(loginResult.email&&loginResult.email.length>0){
        self.field1.text = loginResult.email;
        [self.unbindButton setHidden:NO];
        [self.topBar.rightButton setEnabled:NO];
    }else{
        [self.unbindButton setHidden:YES];
    }
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
    //CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    [topBar setRightButtonText:NSLocalizedString(@"save", nil)];
    [topBar.rightButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"bind_email",nil)];
    [self.view addSubview:topBar];
    self.topBar = topBar;
    [topBar release];
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_email", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field1 = field1;
    [self.view addSubview:field1];
    [field1 release];
    
    
    //解除绑定按钮
    UIButton *unbindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [unbindButton setFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, self.field1.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, 34)];
    UIImage *unbindButtonImage = [UIImage imageNamed:@"bg_blue_button"];
    UIImage *unbindButtonImage_p = [UIImage imageNamed:@"bg_blue_button_p"];
    unbindButtonImage = [unbindButtonImage stretchableImageWithLeftCapWidth:unbindButtonImage.size.width*0.5 topCapHeight:unbindButtonImage.size.height*0.5];
    unbindButtonImage_p = [unbindButtonImage_p stretchableImageWithLeftCapWidth:unbindButtonImage_p.size.width*0.5 topCapHeight:unbindButtonImage_p.size.height*0.5];
    [unbindButton setBackgroundImage:unbindButtonImage forState:UIControlStateNormal];
    [unbindButton setBackgroundImage:unbindButtonImage_p forState:UIControlStateHighlighted];
    [unbindButton addTarget:self action:@selector(onUnbindEmail) forControlEvents:UIControlEventTouchUpInside];
    [unbindButton setTitle:NSLocalizedString(@"unbind_email", nil) forState:UIControlStateNormal];
    [self.view addSubview:unbindButton];
    self.unbindButton = unbindButton;
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];
}

-(void)onUnbindEmail{
    //当field1处于编辑状态时，若不书写此行代码，则iOS8.4会崩溃
    [self.field1 resignFirstResponder];
    
    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_login_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    inputAlert.tag = ALERT_TAG_UNBIND_EMAIL_AFTER_INPUT_PASSWORD;
    [inputAlert show];
    [inputAlert release];
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onSavePress{
    [self.field1 resignFirstResponder];
    
    NSString *email = self.field1.text;
    
    if(!email||!email.length>0){
        [self.view makeToast:NSLocalizedString(@"input_email", nil)];
        return;
    }
    
    if(email.length<5||email.length>31){
        [self.view makeToast:NSLocalizedString(@"email_length_error", nil)];
        return;
    }
    
    //邮箱格式错误
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailFormat = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if(![emailFormat evaluateWithObject:email]){
        [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
        return;
    }
    
    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_login_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    inputAlert.tag = ALERT_TAG_BIND_EMAIL_AFTER_INPUT_PASSWORD;
    [inputAlert show];
    [inputAlert release];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_BIND_EMAIL_AFTER_INPUT_PASSWORD:
        {
            if(buttonIndex==1){
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                NSString *inputPwd = passwordField.text;
                NSString *email = self.field1.text;
                
                if(!inputPwd||inputPwd.length==0){
                    [self.view makeToast:NSLocalizedString(@"input_login_password", nil)];
                    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_login_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    inputAlert.tag = ALERT_TAG_BIND_EMAIL_AFTER_INPUT_PASSWORD;
                    [inputAlert show];
                    [inputAlert release];
                    return;
                }
                
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                
                LoginResult *loginResult = [UDManager getLoginInfo];
                [[NetManager sharedManager] setAccountInfo:loginResult.contactId password:inputPwd phone:loginResult.phone email:email countryCode:loginResult.countryCode phoneCheckCode:@"" flag:@"2" sessionId:loginResult.sessionId callBack:^(id JSON){
                    [self.progressAlert hide:YES];
                    NSInteger error_code = (NSInteger)JSON;
                    switch (error_code) {
                        case NET_RET_SET_ACCOUNT_SUCCESS:
                        {
                            loginResult.email = email;
                            [UDManager setLoginInfo:loginResult];
                            [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                sleep(1.0);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.navigationController popViewControllerAnimated:YES];
                                });
                            });
                            
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_PASSWORD_ERROR:
                        {
                            [self.view makeToast:NSLocalizedString(@"password_error", nil)];
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_EMAIL_USED:
                        {
                            [self.view makeToast:NSLocalizedString(@"email_used", nil)];
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_EMAIL_FORMAT_ERROR:
                        {
                            [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
                        }
                            break;
                        default:
                        {
                            [self.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"unknown_error", nil),error_code]];
                        }
                            break;
                    }
                }];
            }
        }
            break;
        case ALERT_TAG_UNBIND_EMAIL_AFTER_INPUT_PASSWORD:
        {
            if(buttonIndex==1){
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                NSString *inputPwd = passwordField.text;
                
                if(!inputPwd||inputPwd.length==0){
                    [self.view makeToast:NSLocalizedString(@"input_login_password", nil)];
                    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_login_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    inputAlert.tag = ALERT_TAG_UNBIND_EMAIL_AFTER_INPUT_PASSWORD;
                    [inputAlert show];
                    [inputAlert release];
                    return;
                }
                
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                
                LoginResult *loginResult = [UDManager getLoginInfo];
                [[NetManager sharedManager] setAccountInfo:loginResult.contactId password:inputPwd phone:loginResult.phone email:@"" countryCode:loginResult.countryCode phoneCheckCode:@"" flag:@"2" sessionId:loginResult.sessionId callBack:^(id JSON){
                    [self.progressAlert hide:YES];
                    NSInteger error_code = (NSInteger)JSON;
                    switch (error_code) {
                        case NET_RET_SET_ACCOUNT_SUCCESS:
                        {
                            loginResult.email = @"";
                            [UDManager setLoginInfo:loginResult];
                            [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                sleep(1.0);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.navigationController popViewControllerAnimated:YES];
                                });
                            });
                            
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_PASSWORD_ERROR:
                        {
                            [self.view makeToast:NSLocalizedString(@"password_error", nil)];
                        }
                            break;
                        default:
                        {
                            [self.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"unknown_error", nil),error_code]];
                        }
                            break;
                    }
                }];
            }
        }
            break;
        
            
    }
}

#pragma mark - UITextFieldTextDidChangeNotification
//已经开始编辑
- (void)textFieldChanged:(id)sender{
    LoginResult *loginResult = [UDManager getLoginInfo];
    if (![self.field1.text isEqualToString:loginResult.email]) {
        [self.topBar.rightButton setEnabled:YES];
    }else{
        [self.topBar.rightButton setEnabled:NO];
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
@end
