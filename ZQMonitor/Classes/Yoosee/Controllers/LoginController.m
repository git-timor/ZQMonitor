

#import "LoginController.h"
#import "Constants.h"
#import "Utils.h"
#import "Toast+UIView.h"
#import "NetManager.h"
#import "MBProgressHUD.h"
#import "MainController.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "AccountResult.h"
#import "Toast+UIView.h"
#import "ChooseCountryController.h"
#import "EmailRegisterController.h"
#import "BindPhoneController.h"
#import "CheckNewMessageResult.h"
#import "GetContactMessageResult.h"
#import "P2PMessage.h"
#import "MessageDAO.h"
#import "FListManager.h"
#import "ContactDAO.h"
#import "NewRegisterController.h"

#define Remember_PWD_User_Btn 1001
#define Remember_PWD_Phone_Btn 1002

@interface LoginController ()
{
    BOOL _isShowingRememberPwdPrompt;
}
@end

@implementation LoginController

-(void)dealloc{
    [self.usernameField1 release];
    [self.passwrodField1 release];
    [self.progressAlert release];
    [self.leftLabel release];
    [self.rightLabel release];
    [self.countryCode release];
    [self.countryName release];
    [self.lastRegisterId release];
    [self.rememberPwdPrompt release];//记住用户的登录密码
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

-(void)viewDidAppear:(BOOL)animated{
    /*
     *设置通知监听者，监听键盘的显示、收起通知
     */
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    /*
     *手机号登录时，设置国码和国名字
     */
    if(!self.countryCode||!(self.countryCode.length>0)){
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        if([language hasPrefix:@"zh"]){
            self.countryCode = @"86";
            self.countryName = NSLocalizedString(@"china", nil);
        }else{
            self.countryCode = @"1";
            self.countryName = NSLocalizedString(@"america", nil);
        }
        
        
        
    }
    
    /*
     *将已经存在的注册ID显示在用户名区
     */
    if(self.lastRegisterId&&self.lastRegisterId.length>0){
        self.usernameField1.text = self.lastRegisterId;
    }
    
    /*
     *leftLabel显示国码
     *rightLabel显示国家名字
     */
    self.leftLabel.text = [NSString stringWithFormat:@"+%@",self.countryCode];
    self.rightLabel.text = self.countryName;
    
    /*
     *没有理解？
     */
    if(self.isSessionIdError){
        self.isSessionIdError = !self.isSessionIdError;
        [self.view makeToast:NSLocalizedString(@"session_error", nil) duration:2.0 position:@"center"];
        
    }
    
    //new added
    if(self.isP2PVerifyCodeError){
        self.isP2PVerifyCodeError = !self.isP2PVerifyCodeError;
        NSString *codeError = [NSString stringWithFormat:@"%@(46)",NSLocalizedString(@"id_internal_error", nil)];
        [self.view makeToast:codeError duration:2.0 position:@"center"];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    /*
     *移除对键盘将要显示、收起的监听
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
     *初始化用户登录的类型，分别是邮箱登录、手机号登录
     *0表示邮箱登录；1表示手机号登录
     */
    self.loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"LOGIN_TYPE"];
    [self initComponent];
    
    
   
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define LOGO_IMAGE_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100:80)
#define LOGO_IMAGE_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100:80)
#define LOGIN_BTN_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:38)
#define SEGMENT_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:38)

#define REGISTER_ICON_WIDTH_AND_HEIGHT 24

#define ANONYMOUS_BTN_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 50:30)
#define ANONYMOUS_BTN_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100:100)

-(void)initComponent{
    [self.view setBackgroundColor:XBgColor];

    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    self.progressAlert.labelText = NSLocalizedString(@"logging",nil);
    

    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    /*
     *TopBar(继承UIView)
     *自定义一个假的导航，显示在导航栏位置
     */
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"account_login",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(ClickBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    //logo image
    UIImage *imgLogo = [UIImage imageNamed:@"company_app_logo.png"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((width-LOGO_IMAGE_WIDTH)/2, NAVIGATION_BAR_HEIGHT+20, LOGO_IMAGE_WIDTH, LOGO_IMAGE_HEIGHT)];
    logoImageView.image = imgLogo;
    [self.view addSubview:logoImageView];
    [logoImageView release];
    
    //login register view
    UIView *lrView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+20+LOGO_IMAGE_HEIGHT+20, width, (height-(NAVIGATION_BAR_HEIGHT+20+LOGO_IMAGE_HEIGHT+20)))];
    lrView.backgroundColor = [UIColor clearColor];
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"email_id_login", nil),NSLocalizedString(@"phone_login", nil)]];
    [segment addTarget:self action:@selector(onLoginTypeChange:) forControlEvents:UIControlEventValueChanged];
    segment.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 0, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, SEGMENT_HEIGHT);
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    segment.selectedSegmentIndex = self.loginType;
    [lrView addSubview:segment];
    [segment release];
    

    /*
     *mainView1表示邮箱登录界面
     */
    UIView *mainView1 = [[UIView alloc] initWithFrame:CGRectMake(0, SEGMENT_HEIGHT+10, width, lrView.frame.size.height-SEGMENT_HEIGHT-10)];
    
    //username
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 0, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_username", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    field1.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_NAME"];
    [mainView1 addSubview:field1];
    self.usernameField1 = field1;
    [field1 release];
    
    //password
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        field2.layer.borderWidth = 1;
        field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field2.layer.cornerRadius = 5.0;
    }
    field2.textAlignment = NSTextAlignmentLeft;
    field2.placeholder = NSLocalizedString(@"input_password", nil);
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    field2.secureTextEntry = YES;
    field2.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_PWD"];//记住用户的登录密码
    [mainView1 addSubview:field2];
    self.passwrodField1 = field2;
    [field2 release];
    //记住用户的登录密码
    //增加一个按钮，根据用户的需求，是否要记住密码
    UIButton *rememberPwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rememberPwdBtn.frame = CGRectMake(self.passwrodField1.frame.size.width-self.passwrodField1.frame.size.height, 0.0, self.passwrodField1.frame.size.height, self.passwrodField1.frame.size.height);
    rememberPwdBtn.tag = Remember_PWD_User_Btn;
    [rememberPwdBtn addTarget:self action:@selector(btnClickToRememberOrNot:) forControlEvents:UIControlEventTouchUpInside];
    //按钮图片
    //图片与按钮框上、右、下、左之间的距离
    CGFloat space_btnImg_BtnBorder = 10.0;
    //图片的宽、高
    CGFloat btnImg_wh = rememberPwdBtn.frame.size.height-space_btnImg_BtnBorder*2;
    UIImageView *btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(space_btnImg_BtnBorder, space_btnImg_BtnBorder, btnImg_wh, btnImg_wh)];
    NSString *rememberUserPwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_PWD"];
    if (rememberUserPwd && rememberUserPwd.length>0) {
        self.isRememberUserPWD = YES;
        btnImageView.image = [UIImage imageNamed:@"ic_remember_pwd.png"];
    }else{
        self.isRememberUserPWD = NO;
        btnImageView.image = [UIImage imageNamed:@"ic_unremember_pwd.png"];
    }
    [rememberPwdBtn addSubview:btnImageView];
    [self.passwrodField1 addSubview:rememberPwdBtn];
    
    
    /* 登陆button */
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    loginBtn.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, TEXT_FIELD_HEIGHT*2+10, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, LOGIN_BTN_HEIGHT);
    UIImage *loginBtnBackImg = [UIImage imageNamed:@"bg_button.png"];
    loginBtnBackImg = [loginBtnBackImg stretchableImageWithLeftCapWidth:loginBtnBackImg.size.width*0.5 topCapHeight:loginBtnBackImg.size.height*0.5];
    
    UIImage *loginBtnBackImg_p = [UIImage imageNamed:@"bg_button_p.png"];
    loginBtnBackImg_p = [loginBtnBackImg_p stretchableImageWithLeftCapWidth:loginBtnBackImg_p.size.width*0.5 topCapHeight:loginBtnBackImg_p.size.height*0.5];
    
    [loginBtn setBackgroundImage:loginBtnBackImg forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:loginBtnBackImg_p forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(onLoginPress:) forControlEvents:UIControlEventTouchUpInside];
    [mainView1 addSubview:loginBtn];
    
    
    /* 新用户注册button */
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    registerBtn.layer.cornerRadius = 3.0;
    [registerBtn setTitle:NSLocalizedString(@"new_account_register", nil) forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    registerBtn.frame = CGRectMake(width/2-NORMAL_BUTTON_MARGIN_LEFT_AND_RIGHT,mainView1.frame.size.height-10-LOGIN_BTN_HEIGHT, NORMAL_BUTTON_MARGIN_LEFT_AND_RIGHT*2, LOGIN_BTN_HEIGHT);
    [registerBtn addTarget:self action:@selector(onRegisterPress) forControlEvents:UIControlEventTouchUpInside];
    [mainView1 addSubview:registerBtn];
    
    //forget password
    CGFloat forgetLabelWidth1 = [Utils getStringWidthWithString:NSLocalizedString(@"forget_password", nil) font:XFontBold_14 maxWidth:width];
    
    UIButton *forgetButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetButton1.frame = CGRectMake(width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT-forgetLabelWidth1, loginBtn.frame.origin.y+LOGIN_BTN_HEIGHT+10, forgetLabelWidth1, TEXT_FIELD_HEIGHT);
    UILabel *forgetLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,forgetButton1.frame.size.width,forgetButton1.frame.size.height)];
    forgetLabel1.textAlignment = NSTextAlignmentRight;
    forgetLabel1.textColor = XBlack;
    forgetLabel1.backgroundColor = XBGAlpha;
    forgetLabel1.text = NSLocalizedString(@"forget_password", nil);
    forgetLabel1.font = XFontBold_14;
    [forgetButton1 addSubview:forgetLabel1];
    [forgetLabel1 release];
    [forgetButton1 addTarget:self action:@selector(onForgetPassword:) forControlEvents:UIControlEventTouchUpInside];
    
    [mainView1 addSubview:forgetButton1];
    
    
    self.mainView1 = mainView1;
    [lrView addSubview:mainView1];
    [mainView1 release];
    
    /*
     *mainView2表示手机号登录界面
     */
    UIView *mainView2 = [[UIView alloc] initWithFrame:CGRectMake(0, SEGMENT_HEIGHT+10, width, lrView.frame.size.height-SEGMENT_HEIGHT-10)];
    
    UIButton *chooseCountryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    chooseCountryBtn.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 0, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
    chooseCountryBtn.layer.cornerRadius = 2.0;
    chooseCountryBtn.layer.borderWidth = 1.0;
    chooseCountryBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    chooseCountryBtn.backgroundColor = XWhite;
    [chooseCountryBtn addTarget:self action:@selector(onChooseCountryPress:) forControlEvents:UIControlEventTouchUpInside];
    [chooseCountryBtn addTarget:self action:@selector(lightButton:) forControlEvents:UIControlEventTouchDown];
    [chooseCountryBtn addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchCancel];
    [chooseCountryBtn addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
    [chooseCountryBtn addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, chooseCountryBtn.frame.size.width/3, chooseCountryBtn.frame.size.height)];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.backgroundColor = XBGAlpha;
    leftLabel.textColor = XBlack;
    leftLabel.font = XFontBold_16;
    self.leftLabel = leftLabel;
    [leftLabel release];
    [chooseCountryBtn addSubview:self.leftLabel];
    
    UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(chooseCountryBtn.frame.size.width/3, 1, 0.5, chooseCountryBtn.frame.size.height-2)];
    separator.backgroundColor = [UIColor grayColor];
    [chooseCountryBtn addSubview:separator];
    [separator release];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(chooseCountryBtn.frame.size.width/3+0.5, 0, chooseCountryBtn.frame.size.width/3*2-0.5, chooseCountryBtn.frame.size.height)];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.backgroundColor = XBGAlpha;
    rightLabel.textColor = XBlack;
    rightLabel.font = XFontBold_16;
    self.rightLabel = rightLabel;
    [rightLabel release];
    [chooseCountryBtn addSubview:self.rightLabel];
    
    [mainView2 addSubview: chooseCountryBtn];

    //phone number
    UITextField *field3 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, chooseCountryBtn.frame.origin.y+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        field3.layer.borderWidth = 1;
        field3.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field3.layer.cornerRadius = 5.0;
    }
    field3.textAlignment = NSTextAlignmentLeft;
    field3.placeholder = NSLocalizedString(@"input_phone", nil);
    field3.borderStyle = UITextBorderStyleRoundedRect;
    field3.returnKeyType = UIReturnKeyDone;
    field3.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field3 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    field3.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field3.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PHONE_NUMBER"];
    [mainView2 addSubview:field3];
    self.usernameField2 = field3;
    
    //password
    UITextField *field4 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, field3.frame.origin.y+TEXT_FIELD_HEIGHT ,width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        field4.layer.borderWidth = 1;
        field4.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field4.layer.cornerRadius = 5.0;
    }
    field4.textAlignment = NSTextAlignmentLeft;
    field4.placeholder = NSLocalizedString(@"input_password", nil);
    field4.borderStyle = UITextBorderStyleRoundedRect;
    field4.returnKeyType = UIReturnKeyDone;
    field4.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field4 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    field4.secureTextEntry = YES;
    field4.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PHONE_PWD"];//记住用户的登录密码
    [mainView2 addSubview:field4];
    self.passwrodField2 = field4;
    //记住用户的登录密码
    //增加一个按钮，根据用户的需求，是否要记住密码
    UIButton *rememberPwdBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    rememberPwdBtn2.frame = CGRectMake(self.passwrodField2.frame.size.width-self.passwrodField2.frame.size.height, 0.0, self.passwrodField2.frame.size.height, self.passwrodField2.frame.size.height);
    rememberPwdBtn2.tag = Remember_PWD_Phone_Btn;
    [rememberPwdBtn2 addTarget:self action:@selector(btnClickToRememberOrNot:) forControlEvents:UIControlEventTouchUpInside];
    //按钮图片
    //图片与按钮框上、右、下、左之间的距离
    CGFloat space_btnImg_BtnBorder2 = 10.0;
    //图片的宽、高
    CGFloat btnImg_wh2 = rememberPwdBtn2.frame.size.height-space_btnImg_BtnBorder2*2;
    UIImageView *btnImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(space_btnImg_BtnBorder2, space_btnImg_BtnBorder2, btnImg_wh2, btnImg_wh2)];
    NSString *rememberPhonePwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"PHONE_PWD"];
    if (rememberPhonePwd && rememberPhonePwd.length>0) {
        self.isRememberPhonePWD = YES;
        btnImageView2.image = [UIImage imageNamed:@"ic_remember_pwd.png"];
    }else{
        self.isRememberPhonePWD = NO;
        btnImageView2.image = [UIImage imageNamed:@"ic_unremember_pwd.png"];
    }
    [rememberPwdBtn2 addSubview:btnImageView2];
    [self.passwrodField2 addSubview:rememberPwdBtn2];
    
    
    //login button
    UIButton *loginBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn2 setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    loginBtn2.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, field4.frame.origin.y+TEXT_FIELD_HEIGHT+10, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, LOGIN_BTN_HEIGHT);
    UIImage *loginBtnBackImg2 = [UIImage imageNamed:@"bg_button.png"];
    loginBtnBackImg2 = [loginBtnBackImg2 stretchableImageWithLeftCapWidth:loginBtnBackImg2.size.width*0.5 topCapHeight:loginBtnBackImg2.size.height*0.5];
    
    UIImage *loginBtnBackImg_p2 = [UIImage imageNamed:@"bg_button_p.png"];
    loginBtnBackImg_p2 = [loginBtnBackImg_p2 stretchableImageWithLeftCapWidth:loginBtnBackImg_p2.size.width*0.5 topCapHeight:loginBtnBackImg_p2.size.height*0.5];
    
    [loginBtn2 setBackgroundImage:loginBtnBackImg2 forState:UIControlStateNormal];
    [loginBtn2 setBackgroundImage:loginBtnBackImg_p2 forState:UIControlStateHighlighted];
    [loginBtn2 addTarget:self action:@selector(onLoginPress:) forControlEvents:UIControlEventTouchUpInside];
    [mainView2 addSubview:loginBtn2];

    [field3 release];
    [field4 release];
    
    /* mainView2 注册button*/
    UIButton *registerBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn2.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    registerBtn2.layer.cornerRadius = 3.0;
    [registerBtn2 setTitle:NSLocalizedString(@"new_account_register", nil) forState:UIControlStateNormal];
    [registerBtn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    registerBtn2.frame = CGRectMake(width/2-NORMAL_BUTTON_MARGIN_LEFT_AND_RIGHT,mainView2.frame.size.height-10-LOGIN_BTN_HEIGHT, NORMAL_BUTTON_MARGIN_LEFT_AND_RIGHT*2, LOGIN_BTN_HEIGHT);
    [registerBtn2 addTarget:self action:@selector(onRegisterPress) forControlEvents:UIControlEventTouchUpInside];
    [mainView2 addSubview:registerBtn2];

    //forget password
    CGFloat forgetLabelWidth2 = [Utils getStringWidthWithString:NSLocalizedString(@"forget_password", nil) font:XFontBold_14 maxWidth:width];
    
    UIButton *forgetButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetButton2.frame = CGRectMake(width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT-forgetLabelWidth2, loginBtn2.frame.origin.y+10+LOGIN_BTN_HEIGHT, forgetLabelWidth2, TEXT_FIELD_HEIGHT);
    UILabel *forgetLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,forgetButton2.frame.size.width,forgetButton2.frame.size.height)];
    forgetLabel2.textAlignment = NSTextAlignmentRight;
    forgetLabel2.textColor = XBlack;
    forgetLabel2.backgroundColor = XBGAlpha;
    forgetLabel2.text = NSLocalizedString(@"forget_password", nil);
    forgetLabel2.font = XFontBold_14;
    [forgetButton2 addSubview:forgetLabel2];
    [forgetLabel2 release];
    [forgetButton2 addTarget:self action:@selector(onForgetPassword:) forControlEvents:UIControlEventTouchUpInside];
    
    [mainView2 addSubview:forgetButton2];
    
    self.mainView2 = mainView2;
    [lrView addSubview:mainView2];
    [mainView2 release];
    [self.view addSubview:lrView];
    [lrView release];
    
    /*
     *初始化默认的登录界面
     */
    if(self.loginType==0){
        [self.mainView1 setHidden:NO];
        [self.mainView2 setHidden:YES];
    }else{
        [self.mainView1 setHidden:YES];
        [self.mainView2 setHidden:NO];
    }
    [self.view addSubview:self.progressAlert];
    
    
    //记住用户的登录密码
    //点击记住或不记住按钮时，弹出的提示
    CGFloat rememberPwdPrompt_w = 180.0;
    CGFloat rememberPwdPrompt_h = 80.0;
    //图标宽、高
    CGFloat imageViewPrompt_wh = 20.0;
    //文字宽、高
    CGFloat labelPrompt_w = [Utils getStringWidthWithString:NSLocalizedString(@"un_rem_pass", nil) font:XFontBold_16 maxWidth:width];
    CGFloat labelPrompt_h = [Utils getStringHeightWithString:NSLocalizedString(@"un_rem_pass", nil) font:XFontBold_16 maxWidth:width];
    CGFloat space = (rememberPwdPrompt_h-imageViewPrompt_wh-labelPrompt_h)/3;
    
    UIView *rememberPwdPrompt = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-rememberPwdPrompt_w)/2, (self.view.frame.size.height-rememberPwdPrompt_h)/2, rememberPwdPrompt_w, rememberPwdPrompt_h)];
    rememberPwdPrompt.backgroundColor = UIColorFromRGBA(0x00000090);
    rememberPwdPrompt.layer.cornerRadius = 5.0;
    rememberPwdPrompt.layer.borderColor = UIColorFromRGB(0x444242).CGColor;
    rememberPwdPrompt.layer.borderWidth = 2.0;
    [self.view addSubview:rememberPwdPrompt];
    self.rememberPwdPrompt = rememberPwdPrompt;
    [self.rememberPwdPrompt setHidden:YES];
    _isShowingRememberPwdPrompt = NO;
    [rememberPwdPrompt release];
    //图标提示
    UIImageView *imageViewPrompt = [[UIImageView alloc] initWithFrame:CGRectMake((self.rememberPwdPrompt.frame.size.width-imageViewPrompt_wh)/2, space, imageViewPrompt_wh, imageViewPrompt_wh)];
    [rememberPwdPrompt addSubview:imageViewPrompt];
    [imageViewPrompt release];
    //文字提示
    UILabel *labelPrompt = [[UILabel alloc] initWithFrame:CGRectMake((self.rememberPwdPrompt.frame.size.width-labelPrompt_w)/2, space*2+imageViewPrompt_wh, labelPrompt_w, labelPrompt_h)];
    labelPrompt.backgroundColor = XBGAlpha;
    labelPrompt.font = XFontBold_16;
    labelPrompt.textColor = UIColorFromRGB(0x52a0e0);
    labelPrompt.textAlignment = NSTextAlignmentCenter;
    [rememberPwdPrompt addSubview:labelPrompt];
    [labelPrompt release];
}

#pragma mark - 显示记住或不记住密码提示
-(void)showRememberPwdPrompt:(BOOL)isRememberPwd{//记住用户的登录密码
    UIImageView *imageViewPrompt = [[self.rememberPwdPrompt subviews] objectAtIndex:0];
    UILabel *labelPrompt = [[self.rememberPwdPrompt subviews] objectAtIndex:1];
    if (isRememberPwd) {
        imageViewPrompt.image = [UIImage imageNamed:@"ic_remember_pwd.png"];
        labelPrompt.text = NSLocalizedString(@"rem_pass", nil);
    }else{
        imageViewPrompt.image = [UIImage imageNamed:@"ic_unremember_pwd.png"];
        labelPrompt.text = NSLocalizedString(@"un_rem_pass", nil);
    }
    [self.rememberPwdPrompt setHidden:NO];
    _isShowingRememberPwdPrompt = YES;
    
    
    self.rememberPwdPrompt.transform = CGAffineTransformMakeScale(1, 0.1);
    [UIView transitionWithView:self.rememberPwdPrompt duration:0.1 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGAffineTransform transform1 = CGAffineTransformScale(self.rememberPwdPrompt.transform, 1, 10);
                        self.rememberPwdPrompt.transform = transform1;
                    }
                    completion:^(BOOL finished){
                        usleep(800000);
                        [UIView transitionWithView:self.rememberPwdPrompt duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                                        animations:^{
                                            
                                            CGAffineTransform transform1 = CGAffineTransformScale(self.rememberPwdPrompt.transform, 1, 0.1);
                                            self.rememberPwdPrompt.transform = transform1;
                                        }
                                        completion:^(BOOL finished){
                                            [self.rememberPwdPrompt setHidden:YES];
                                            _isShowingRememberPwdPrompt = NO;
                                        }
                         ];
                    }
     ];
}


#pragma mark - 是否要记住登录密码
-(void)btnClickToRememberOrNot:(UIButton *)button{//记住用户的登录密码
    if (_isShowingRememberPwdPrompt) {
        return;
    }
    
    if (button.tag == Remember_PWD_User_Btn) {
        UIImageView *btnImageView = [[button subviews] objectAtIndex:0];
        
        if (self.isRememberUserPWD) {
            //表示不记住用户的登录密码
            self.isRememberUserPWD = NO;
            btnImageView.image = [UIImage imageNamed:@"ic_unremember_pwd.png"];
            [self showRememberPwdPrompt:NO];
        }else{
            //记住登录密码
            self.isRememberUserPWD = YES;
            btnImageView.image = [UIImage imageNamed:@"ic_remember_pwd.png"];
            [self showRememberPwdPrompt:YES];
        }
    }else{
        UIImageView *btnImageView2 = [[button subviews] objectAtIndex:0];
        
        if (self.isRememberPhonePWD) {
            //表示不记住用户的登录密码
            self.isRememberPhonePWD = NO;
            btnImageView2.image = [UIImage imageNamed:@"ic_unremember_pwd.png"];
            [self showRememberPwdPrompt:NO];
        }else{
            //记住登录密码
            self.isRememberPhonePWD = YES;
            btnImageView2.image = [UIImage imageNamed:@"ic_remember_pwd.png"];
            [self showRememberPwdPrompt:YES];
        }
    }
}

//#pragma mark - 监听键盘
//#pragma mark 键盘将要显示时，调用
//-(void)onKeyBoardWillShow:(NSNotification*)notification{
//    NSDictionary *userInfo = [notification userInfo];
//    //keyBoard frame
//    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    DLog(@"%f",rect.size.height);
//    
//    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
//                    animations:^{
//                        CGFloat offset1;//login button 以下的height
//                        if (self.loginType == 0) {
//                            offset1 = self.mainView1.frame.size.height-(self.passwrodField1.frame.origin.y+self.passwrodField1.frame.size.height+10+LOGIN_BTN_HEIGHT);
//                        }else{
//                            offset1 = self.mainView2.frame.size.height-(self.passwrodField2.frame.origin.y+self.passwrodField2.frame.size.height+10+LOGIN_BTN_HEIGHT);
//                        }
//                        CGFloat finalOffset;
//                        if(offset1-rect.size.height<0){
//                            finalOffset = rect.size.height-offset1+10;
//                        }else {
//                            if(offset1-rect.size.height>=10){
//                                finalOffset = 0;
//                            }else{
//                                finalOffset = 10-(offset1-rect.size.height);
//                            }
//                        }
//                        self.view.transform = CGAffineTransformMakeTranslation(0, -finalOffset);
//                    }
//                    completion:^(BOOL finished) {
//                        
//                    }
//     ];
//}
//
//#pragma mark 键盘将要收起时，调用
//-(void)onKeyBoardWillHide:(NSNotification*)notification{
//    DLog(@"onKeyBoardWillHide");
//    
//    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
//                    animations:^{
//                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
//                    }
//                    completion:^(BOOL finished) {
//                        
//                    }
//     ];
//}
//
-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

-(void)hideKeyBoard{//click login button to call
    if(self.loginType==0){
        [self.usernameField1 resignFirstResponder];
        [self.passwrodField1 resignFirstResponder];
    }else{
        [self.usernameField2 resignFirstResponder];
        [self.passwrodField2 resignFirstResponder];
    }
}

-(void)onProgressAlertExit{
    sleep(1.5);
    [self.view makeToast:NSLocalizedString(@"user_unexist", nil)];
}

-(void)lightButton:(UIView*)view{
    view.backgroundColor = XBlue;
}

-(void)normalButton:(UIView*)view{
    view.backgroundColor = XWhite;
}

-(void)onForgetPassword:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cloudlinks.cn/pw/"]];
}

#pragma mark - 调用时，进入国家选择界面
-(void)onChooseCountryPress:(UIButton*)button{
    [self normalButton:button];
    ChooseCountryController *chooseCountryController = [[ChooseCountryController alloc] init];
    chooseCountryController.loginController = self;
    [self presentViewController:chooseCountryController animated:YES completion:nil];
    [chooseCountryController release];
}

#pragma mark - 选择登录界面：邮箱登录和手机号登录
-(void)onLoginTypeChange:(UISegmentedControl*)control{
    
    self.loginType = control.selectedSegmentIndex;
    
    if(self.loginType==0){
        [self.mainView1 setHidden:NO];
        [self.mainView2 setHidden:YES];
        [self.usernameField2 resignFirstResponder];
        [self.passwrodField2 resignFirstResponder];
    }else{
        [self.mainView1 setHidden:YES];
        [self.mainView2 setHidden:NO];
        [self.usernameField1 resignFirstResponder];
        [self.passwrodField1 resignFirstResponder];
    }
}

#pragma mark - 进入手机号码注册界面
-(void)onPhoneRegisterPress{
    BindPhoneController *bindPhoneController = [[BindPhoneController alloc] init];
    bindPhoneController.isRegister = YES;
    bindPhoneController.loginController = self;
    [self.navigationController pushViewController:bindPhoneController animated:YES];
    [bindPhoneController release];
}

#pragma mark - 进入邮箱注册界面
-(void)onEmailRegisterPress{
    EmailRegisterController *emailRegisterController = [[EmailRegisterController alloc] init];
    emailRegisterController.loginController = self;
    [self.navigationController pushViewController:emailRegisterController animated:YES];
    [emailRegisterController release];
}

#pragma mark - 进入匿名登录界面
-(void)onAnonymousLoginPress:(id)sender{
    [UDManager setIsLogin:YES];
    LoginResult *loginResult = [[LoginResult alloc] init];
    loginResult.contactId = @"0517400";
    loginResult.rCode1 = @"0";
    loginResult.rCode2 = @"0";
    loginResult.sessionId = @"0";

    [UDManager setLoginInfo:loginResult];
    [loginResult release];
    
    MainController *mainController = [[MainController alloc] init];
    self.view.window.rootViewController = mainController;
    [[AppDelegate sharedDefault] setMainController:mainController];
    [mainController release];
}

#pragma mark - 点击登录按钮
-(void)onLoginPress:(id)sender{
    [self hideKeyBoard];
    
    if(self.loginType==0){
    NSString *username = self.usernameField1.text;
    NSString *password = self.passwrodField1.text;

    /*
     *根据用户输入的信息完整程度，给出相应的提示
     */
    if(!username||!(username.length > 0)){
        
        [self.view makeToast:NSLocalizedString(@"unInputUsername", nil)];
        return;
    }
    
    if([username isValidateNumber]){
        if([username characterAtIndex:0]!='0'){
            self.progressAlert.dimBackground = YES;
            [self.progressAlert showWhileExecuting:@selector(onProgressAlertExit) onTarget:self withObject:Nil animated:YES];
                        return;
        }
    }
    if(!password||!(password.length>0)){
        
        [self.view makeToast:NSLocalizedString(@"unInputPassword", nil)];
        return;
    }
    
    
		
	self.progressAlert.dimBackground = YES;
    
    [self.progressAlert show:YES];
    
    [[NetManager sharedManager] loginWithUserName:username password:password token:[AppDelegate sharedDefault].token callBack:^(id result){
        
        LoginResult *loginResult = (LoginResult*)result;
        [self.progressAlert hide:YES];
        
        //记住用户的登录密码
        if (self.isRememberUserPWD) {
            //用户登录时，则记下用户的登录密码；用于下次登录时，不用再输入PWD
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"USER_PWD"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"USER_PWD"];
        }
        switch(loginResult.error_code){
            case NET_RET_LOGIN_SUCCESS:
            {
                //re-registerForRemoteNotifications
                if(CURRENT_VERSION>=8.0){//8.0以后使用这种方法来注册推送通知
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                    
                    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
                    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                    
                    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
                    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
                }else{
                    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
                }

                DLog(@"contactId:%@",loginResult.contactId);
                DLog(@"Email:%@",loginResult.email);
                DLog(@"Phone:%@",loginResult.phone);
                DLog(@"CountryCode:%@",loginResult.countryCode);
                [UDManager setIsLogin:YES];
                [UDManager setLoginInfo:loginResult];
                [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"USER_NAME"];
                [[NSUserDefaults standardUserDefaults] setInteger:self.loginType forKey:@"LOGIN_TYPE"];
                MainController *mainController = [[MainController alloc] init];
//                self.view.window.rootViewController = mainController;
                
                
                //                self.appDelegate.window.rootViewController = self.appDelegate.mainController;
                [ self . navigationController pushViewController :mainController animated : NO ];
                [[AppDelegate sharedDefault] setMainController:mainController];
                [mainController release];
                
                [[NetManager sharedManager] getAccountInfo:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
                    AccountResult *accountResult = (AccountResult*)JSON;
                    loginResult.email = accountResult.email;
                    loginResult.phone = accountResult.phone;
                    loginResult.countryCode = accountResult.countryCode;
                    [UDManager setLoginInfo:loginResult];
                }];
                
                //关闭此功能
                /*
                [[NetManager sharedManager] checkNewMessage:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
                    CheckNewMessageResult *checkNewMessageResult = (CheckNewMessageResult*)JSON;
                    if(checkNewMessageResult.error_code==NET_RET_CHECK_NEW_MESSAGE_SUCCESS){
                        if(checkNewMessageResult.isNewContactMessage){
                            DLog(@"have new");
                            [[NetManager sharedManager] getContactMessageWithUsername:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
                                NSArray *datas = [NSArray arrayWithArray:JSON];
                                if([datas count]<=0){
                                    return;
                                }
                                BOOL haveContact = NO;
                                for(GetContactMessageResult *result in datas){
                                    DLog(@"%@",result.message);
                                    ContactDAO *contactDAO = [[ContactDAO alloc] init];
                                    Contact *contact = [contactDAO isContact:result.contactId];
                                    if(nil!=contact){
                                        haveContact = YES;
                                    }
                                    [contactDAO release];
                                    
                                    MessageDAO *messageDAO = [[MessageDAO alloc] init];
                                    Message *message = [[Message alloc] init];
                                    
                                    message.fromId = result.contactId;
                                    message.toId = loginResult.contactId;
                                    message.message = [NSString stringWithFormat:@"%@",result.message];
                                    message.state = MESSAGE_STATE_NO_READ;
                                    message.time = [NSString stringWithFormat:@"%@",result.time];
                                    message.flag = result.flag;
                                    [messageDAO insert:message];
                                    [message release];
                                    [messageDAO release];
                                    int lastCount = [[FListManager sharedFList] getMessageCount:result.contactId];
                                    [[FListManager sharedFList] setMessageCountWithId:result.contactId count:lastCount+1];
                                    
                                }
                                if(haveContact){
                                    [Utils playMusicWithName:@"message" type:@"mp3"];
                                }
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                                    object:self
                                                                                  userInfo:nil];
                            }];
                        }
                    }else{
                        
                    }
                }];
                 */

            }
                break;
            case NET_RET_LOGIN_USER_UNEXIST:
            {
                [self.view makeToast:NSLocalizedString(@"user_unexist", nil)];
            }
                break;
            case NET_RET_LOGIN_PWD_ERROR:
            {
                [self.view makeToast:NSLocalizedString(@"password_error", nil)];
            }
                break;
            case NET_RET_LOGIN_EMAIL_FORMAT_ERROR:
            {
                [self.view makeToast:NSLocalizedString(@"user_unexist", nil)];
            }
                break;
                
            default:
            {
                
                [self.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"login_failure", nil),loginResult.error_code]];
            }
                break;
        }
        
    }];
    
    }else{
        NSString *phone = self.usernameField2.text;
        NSString *password = self.passwrodField2.text;
        
        if(!phone||!(phone.length>0)){
            
            [self.view makeToast:NSLocalizedString(@"input_phone", nil)];
            return;
        }
        
        
        if(!password||!(password.length>0)){
            
            [self.view makeToast:NSLocalizedString(@"unInputPassword", nil)];
            return;
        }
        
        
		
        self.progressAlert.dimBackground = YES;
        [self.progressAlert show:YES];
        NSString *username = [NSString stringWithFormat:@"+%@-%@",self.countryCode,phone];
        DLog(@"%@",username);
        [[NetManager sharedManager] loginWithUserName:username password:password token:[AppDelegate sharedDefault].token callBack:^(id result){
            
            LoginResult *loginResult = (LoginResult*)result;
            [self.progressAlert hide:YES];
            
            //记住用户的登录密码
            if (self.isRememberPhonePWD) {
                //用户登录时，则记下用户的登录密码；用于下次登录时，不用再输入PWD
                [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"PHONE_PWD"];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PHONE_PWD"];
            }
            switch(loginResult.error_code){
                case NET_RET_LOGIN_SUCCESS:
                {
                    //re-registerForRemoteNotifications
                    if(CURRENT_VERSION>=8.0){//8.0以后使用这种方法来注册推送通知
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                        
                        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
                        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                        
                        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
                        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
                    }else{
                        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
                    }
                    
                    DLog(@"contactId:%@",loginResult.contactId);
                    DLog(@"Email:%@",loginResult.email);
                    DLog(@"Phone:%@",loginResult.phone);
                    DLog(@"CountryCode:%@",loginResult.countryCode);
                    [UDManager setIsLogin:YES];
                    [UDManager setLoginInfo:loginResult];
                    [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"PHONE_NUMBER"];
                    [[NSUserDefaults standardUserDefaults] setInteger:self.loginType forKey:@"LOGIN_TYPE"];
                    MainController *mainController = [[MainController alloc] init];
                    self.view.window.rootViewController = mainController;
                    [[AppDelegate sharedDefault] setMainController:mainController];
                    [mainController release];
                    
                }
                    break;
                case NET_RET_LOGIN_USER_UNEXIST:
                {
                    [self.view makeToast:NSLocalizedString(@"user_unexist", nil)];
                }
                    break;
                case NET_RET_LOGIN_PWD_ERROR:
                {
                    [self.view makeToast:NSLocalizedString(@"password_error", nil)];
                }
                    break;
                case NET_RET_UNKNOWN_ERROR:
                {
                    [self.view makeToast:NSLocalizedString(@"login_failure", nil)];
                }
                    break;
                    
                default:
                {
                    [self.view makeToast:NSLocalizedString(@"login_failure", nil)];
                }
                    break;
            }
            
        }];
    }
    
}

-(void)onRegisterPress{
    
    NewRegisterController *newRegisterController = [[NewRegisterController alloc]init];
    newRegisterController.loginController = self;
    [self.navigationController pushViewController:newRegisterController animated:YES];
    [newRegisterController release];
}

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

-(void)ClickBack{
    if (_isFromTenementVC == YES) {
        [ self.navigationController popViewControllerAnimated:YES];
        return;
    }
//
    //退出成功
    [UDManager setIsLogin:NO];
    
//    [[GlobalThread sharedThread:NO] kill];
    [[FListManager sharedFList] setIsReloadData:YES];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    //    LoginController *loginController = [[LoginController alloc] init];
    //    AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
    //
    //    self.view.window.rootViewController = mainController;
    //    [loginController release];
    //    [mainController release];
    
    dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
    dispatch_async(queue, ^{
        [[P2PClient sharedClient] p2pDisconnect];
        DLog(@"p2pDisconnect.");
    });
    
    [ self . tabBarController . navigationController popToRootViewControllerAnimated : YES ];
}
@end
