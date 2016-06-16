

#import <UIKit/UIKit.h>
@class MBProgressHUD;
@interface LoginController : UIViewController

@property (strong, nonatomic) UIView *mainView1;
@property (strong, nonatomic) UIView *mainView2;
@property (strong, nonatomic) UITextField *usernameField1;
@property (strong, nonatomic) UITextField *passwrodField1;
@property (strong, nonatomic) UITextField *usernameField2;
@property (strong, nonatomic) UITextField *passwrodField2;

@property (strong, nonatomic) MBProgressHUD *progressAlert;


@property (strong,nonatomic) NSString *countryCode;
@property (strong,nonatomic) NSString *countryName;

@property (strong,nonatomic) UILabel *leftLabel;
@property (strong,nonatomic) UILabel *rightLabel;


@property (assign) NSInteger loginType;
@property (nonatomic) BOOL isSessionIdError;
@property (nonatomic) BOOL isP2PVerifyCodeError;

@property (strong,nonatomic) NSString *lastRegisterId;
//YES表示记住用户的登录密码；NO表示不记住登录密码
@property (nonatomic) BOOL isRememberUserPWD;//记住用户的登录密码
//YES表示记住用户的登录密码；NO表示不记住登录密码
@property (nonatomic) BOOL isRememberPhonePWD;//记住用户的登录密码
@property (strong, nonatomic) UIView *rememberPwdPrompt;//记住用户的登录密码



@property(nonatomic,assign)BOOL isFromTenementVC;
@end
