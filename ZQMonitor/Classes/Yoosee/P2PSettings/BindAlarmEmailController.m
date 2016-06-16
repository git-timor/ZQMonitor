//
//  BindAlarmEmailController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "BindAlarmEmailController.h"
#import "Constants.h"
#import "Contact.h"
#import "TopBar.h"
#import "Toast+UIView.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "AlarmSettingController.h"
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"

@interface BindAlarmEmailController ()
{
    int _getCounts;
    BOOL isTextViewOrTextField;//delete
    
    BOOL _isManual;//YES表示当前处于manualView；NO表示当前处于defaultView
}
@end

@implementation BindAlarmEmailController

-(void)dealloc{
    [self.alarmSettingController release];
    [self.contact release];
    [self.progressAlert release];
    [self.maskLayerView release];
    [self.field1 release];
    [self.subjectTextView release];
    [self.contentTextView release];
    [self.smtpTextField release];
    [self.senderTextField release];
    [self.d_manualBtnView release];
    [self.pwdPromptLabel release];
    [self.pwdTextField release];
    [self.dropDownBtn release];
    [self.emailArray release];
    [self.smtpServerArray release];
    [self.smtpServer release];
    [self.smtpPortArray release];
    [self.smtpPort release];
    [self.unbindButton release];
    [self.defaultView release];//email新调整
    
    [self.manualView release];//email新调整
    [self.m_receiverTextField release];
    [self.m_senderTextField release];
    [self.m_smtpTextField release];
    [self.m_portTextField release];
    [self.m_dropDownBtn release];
    [self.m_tableView release];
    [self.m_pwdTextField release];
    [self.m_encryptBgView release];
    [self.m_encryptView release];
    [self.m_pwdPromptLabel release];
    [self.m_unbindButton release];
    [self.m_manualBtnView release];
    [self.m_portArray release];
    [self.m_pwdPromptLabelText release];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    /*
     *设置通知监听者，监听键盘的显示、收起通知
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];//delete
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];//delete
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //write code here ...
    /*
     *移除对键盘将要显示、收起的监听
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];//delete
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];//delete
    self.contentTextView.text = @"Dear User,\n Please check the attached picture for more information.";//delete
    self.subjectTextView.text = @"Attention: alarm";//delete
    
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    //YES表示取消保存或解除时的指示器，并不接收设备返回的任何数据
    self.isIndicatorCancelled = YES;
    //YES表示APP发送set/get命令成功，ack_receiveRemoteMessage里不用做任何处理
    self.isCommandSentOk = YES;
    
    
    if(self.alarmSettingController.isSMTP == 0){
        //只支持系统默认邮箱(旧设备)的界面初始化
        self.field1.text = self.alarmSettingController.bindEmail;
        //解除绑定按钮
        if(self.alarmSettingController.bindEmail && self.alarmSettingController.bindEmail.length>0){
            [self.unbindButton setHidden:NO];
        }else{
            [self.unbindButton setHidden:YES];
        }
    }else{
        //既支持系统默认邮箱(去掉系统默认)，又支持非系统默认邮箱(新设备)
        
        /*
         *1. view将要显示时，判断显示defaultView，还是显示manualView
         *2. 显示界面manualView条件：
         *   1）收件人个数>=2个
         *   2）收（1个）发件人不相等
         *   3）收（1个）发邮箱相等时，smtp地址不在smtpServerArray数组里
         *   4）收（1个）发邮箱相等时，端口不在smtpPortArray数组里
         *3. 否则显示界面defaultView
         */
        BOOL isShowDefaultView = [self showDefaultViewWhenFirstIntoBindedEmailInterface];
        self.isFirstInterfaceDefaultView = isShowDefaultView;
        if (isShowDefaultView) {
            _isManual = NO;
            
            [self hiddenInitComponentDefautl:NO];
            //展示默认的邮箱绑定界面
            [self showDefaultViewWithInitialization:NO];
            
        }else{
            _isManual = YES;
            
            [self hiddenInitComponentDefautl:YES];
            //展示手动配置的邮箱绑定界面
            [self showManualViewWithInitialization:NO];
        }
    }
    
}

#pragma mark - 判断进入邮箱绑定界面时，显示界面defaultView，还是显示界面manualVie
/*
 *1. 返回值为YES表示要显示defaultView；
 *2. 返回值为NO表示要显示manualVie；
 */
-(BOOL)showDefaultViewWhenFirstIntoBindedEmailInterface{
    //通过收件人与发件人来判断，是要显示defaultView，还是要显示manualVie
    NSString *recipient = self.alarmSettingController.bindEmail;
    NSString *sender = self.alarmSettingController.smtpUser;
    
    if((recipient && recipient.length>0) && (sender && sender.length>0)){//获取到收发邮箱
        NSRange range = [@"," rangeOfString:recipient];
        if (range.length>0) {
            return NO;//收件人个数>=2个
        }
        
        if (![recipient isEqualToString:sender]) {
            return NO;//收（1个）发件人不相等
        }
        
        //收（1个）发邮箱相等时，通过smtp地址和端口来判断
        NSString *smtpServer = self.alarmSettingController.smtpServer;
        NSString *smtpPort = [NSString stringWithFormat:@"%d",self.alarmSettingController.smtpPort];
        
        BOOL isNoneSmtpServer = YES;
        for (int i=0; i<self.smtpServerArray.count; i++) {
            NSRange range1 = [smtpServer rangeOfString:self.smtpServerArray[i]];
            if (range1.length>0) {
                isNoneSmtpServer = NO;
                break;
            }
        }
        if (isNoneSmtpServer) {
            return NO;//smtp地址不在smtpServerArray数组里
        }
        
        BOOL isNoneSmtpPort = YES;
        for (int i=0; i<self.smtpPortArray.count; i++) {
            NSRange range2 = [smtpPort rangeOfString:self.smtpPortArray[i]];
            if (range2.length>0) {
                isNoneSmtpPort = NO;
                break;
            }
        }
        if (isNoneSmtpPort) {
            return NO;//端口不在smtpPortArray数组里
        }
    }
    
    return YES;
}

#pragma mark - 展示手动配置的邮箱绑定界面
-(void)showManualViewWithInitialization:(BOOL)isInitializing{
    /*
     *1. 当进入邮箱绑定的当前界面是defaultView，切换到manualView时
     *2. 为界面manualView赋予初始状态（即清空）
     */
    if (isInitializing) {
        self.m_receiverTextField.text = @"";//收件人
        self.m_senderTextField.text = @"";//发件人
        self.m_smtpTextField.text = @"";//smtp地址
        self.m_portTextField.text = @"";//端口
        self.m_pwdTextField.text = @"";//密码
        
        //隐藏、显示m_encryptView、pwdPromptLabel或解除绑定按钮，相关view位置的调整
        self.m_portTextField.userInteractionEnabled = YES;//默认不可编辑，选择自定义端口时，可编辑
        self.m_isHiddenEncryptView = NO;
        self.m_isHiddenPwdPromptLabel = YES;
        self.m_isHiddenUnbindButton = YES;
        self.m_pwdPromptLabelText = @"";
        [self manualViewHiddenEncryptView:self.m_isHiddenEncryptView hiddenPwdPromptLabel:self.m_isHiddenPwdPromptLabel hiddenUnbindButton:self.m_isHiddenUnbindButton = YES pwdPromptLabelText:self.m_pwdPromptLabelText];
        
        return;
    }
    
    //上一界面获取到的报警邮箱相关信息
    //收件人
    self.m_receiverTextField.text = self.alarmSettingController.bindEmail;
    
    //发件人
    self.m_senderTextField.text = self.alarmSettingController.smtpUser;
    
    //smtp地址
    self.m_smtpTextField.text = self.alarmSettingController.smtpServer;
    
    //端口
    self.m_portTextField.text = [NSString stringWithFormat:@"%d",self.alarmSettingController.smtpPort];
    
    //密码
    self.m_pwdTextField.text = self.alarmSettingController.smtpPwd;
    
    //加密类型
    self.m_encryptType = self.alarmSettingController.encryptType;
    
    //加密方式
    BOOL isNoneSmtpPort = YES;
    for (int i=0; i<self.smtpPortArray.count; i++) {
        NSRange range2 = [self.m_portTextField.text rangeOfString:self.smtpPortArray[i]];
        if (range2.length>0) {
            isNoneSmtpPort = NO;
            break;
        }
    }
    //根据端口显示加密框或者隐藏加密框
    if (isNoneSmtpPort) {
        //端口为自定义时，显示加密框；
        self.m_isHiddenEncryptView = NO;
        self.m_portTextField.userInteractionEnabled = YES;//默认不可编辑，选择自定义端口时，可编辑
        //并且加密框根据加密方式显示相应的加密
        for (id obj in self.m_encryptView.subviews) {
            if ([obj isKindOfClass:[UIButton class]]) {
                UIButton *encryptBtn = (UIButton *)obj;
                if (encryptBtn.tag == self.m_encryptType+10) {
                    encryptBtn.selected = YES;
                }else{
                    encryptBtn.selected = NO;
                }
                
            }
        }
    }else{
        self.m_isHiddenEncryptView = YES;
    }
    
    //提示label
    int isRightPwd = self.alarmSettingController.isRightPwd;
    int isEmailVerified = self.alarmSettingController.isEmailVerified;
    if (isEmailVerified == 1) {//提示邮箱未验证
        self.m_isHiddenPwdPromptLabel = NO;
        self.m_pwdPromptLabelText = NSLocalizedString(@"not_verified", nil);
    }else if (isEmailVerified == 0 && isRightPwd == 0) {//提示密码不匹配
        self.m_isHiddenPwdPromptLabel = NO;
        self.m_pwdPromptLabelText = NSLocalizedString(@"pwd_smtp_error", nil);
    }else{
        self.m_isHiddenPwdPromptLabel = YES;
        self.m_pwdPromptLabelText = @"";
    }
    
    //绑定按钮
    /*
     * 根据收件人显示或者隐藏
     * 1）收件人存在，则显示
     * 2）收件人不存在，则隐藏
     */
    self.m_isHiddenUnbindButton = NO;
    
    
    //隐藏、显示m_encryptView、pwdPromptLabel或解除绑定按钮，相关view位置的调整
    [self manualViewHiddenEncryptView:self.m_isHiddenEncryptView hiddenPwdPromptLabel:self.m_isHiddenPwdPromptLabel hiddenUnbindButton:self.m_isHiddenUnbindButton pwdPromptLabelText:self.m_pwdPromptLabelText];
}

#pragma mark - 展示默认的邮箱绑定界面
-(void)showDefaultViewWithInitialization:(BOOL)isInitializing{
    /*
     *1. 当进入邮箱绑定的当前界面是manualView，切换到defaultView时
     *2. 为界面defaultView赋予初始状态（即清空）
     */
    if (isInitializing) {
        self.senderTextField.text = @"";
        self.pwdTextField.text = @"";
        self.smtpTextField.text = self.emailArray[0];//SMTP服务器
        self.smtpServer = self.smtpServerArray[0];//SMTP服务器
        self.smtpPort = self.smtpPortArray[0];//SMTP端口
        
        //隐藏、显示pwdPromptLabel或解除绑定按钮，相关view位置的调整
        [self hiddenPwdPromptLabel:YES unbindButton:YES pwdPromptLabelText:@""];
        
        return;
    }
    
    //上一界面获取到的报警邮箱相关信息
    int isSMTP = self.alarmSettingController.isSMTP;
    int isRightPwd = self.alarmSettingController.isRightPwd;
    int isEmailVerified = self.alarmSettingController.isEmailVerified;
    NSString *smtpServer = self.alarmSettingController.smtpServer;
    NSString *smtpPort = [NSString stringWithFormat:@"%d",self.alarmSettingController.smtpPort];
    NSString *smtpUser = self.alarmSettingController.smtpUser;
    NSString *smtpPwd = self.alarmSettingController.smtpPwd;
    NSString *bindEmail = self.alarmSettingController.bindEmail;
    //bReserve =0x01则显示手工设置(固件新版本一律回0x01),  否则不显示
    int reserve = self.alarmSettingController.reserve;
    if (reserve != 1) {
        [self.d_manualBtnView setHidden:YES];
    }else{
        [self.d_manualBtnView setHidden:NO];
    }
    
    
    if(bindEmail && bindEmail.length>0){
        NSRange range = [bindEmail rangeOfString:@"@" options:NSBackwardsSearch];
        NSString *preEmail = [bindEmail substringToIndex:range.location];
        NSString *sufEmail = [bindEmail substringFromIndex:range.location];
        
        //1. 发件框
        self.senderTextField.text = preEmail;
        
        //判断收件箱是不是有效的
        BOOL isIvalidEmail = YES;
        for (int i=0; i<self.emailArray.count; i++) {
            NSRange range1 = [bindEmail rangeOfString:self.emailArray[i]];
            if (range1.length>0) {
                //2. 邮局框
                self.smtpTextField.text = self.emailArray[i];//SMTP服务器
                self.smtpServer = self.smtpServerArray[i];//SMTP服务器
                self.smtpPort = self.smtpPortArray[i];//SMTP端口
                isIvalidEmail = NO;
                break;
            }
        }
        if (isIvalidEmail) {
            //2. 邮局框
            self.smtpTextField.text = sufEmail;//SMTP服务器
            self.smtpServer = self.smtpServerArray[0];//SMTP服务器
            self.smtpPort = self.smtpPortArray[0];//SMTP端口
        }
        
        //3. 密码框
        self.pwdTextField.text = smtpPwd;//发件密码
        
        
        if (smtpUser && smtpUser.length > 0) {
            //4. 提示栏
            if (isEmailVerified == 1) {//提示邮箱未验证
                self.pwdPromptLabel.text = NSLocalizedString(@"not_verified", nil);
                
                //隐藏、显示pwdPromptLabel或解除绑定按钮，相关view位置的调整
                [self hiddenPwdPromptLabel:NO unbindButton:NO pwdPromptLabelText:NSLocalizedString(@"not_verified", nil)];
            }else if (isEmailVerified == 0 && isRightPwd == 0) {//提示密码不匹配
                self.pwdPromptLabel.text = NSLocalizedString(@"pwd_error", nil);
                
                //隐藏、显示pwdPromptLabel或解除绑定按钮，相关view位置的调整
                [self hiddenPwdPromptLabel:NO unbindButton:NO pwdPromptLabelText:NSLocalizedString(@"pwd_error", nil)];
            }else{
                //隐藏、显示pwdPromptLabel或解除绑定按钮，相关view位置的调整
                [self hiddenPwdPromptLabel:YES unbindButton:NO pwdPromptLabelText:@""];
            }
        }
        
    }else{
        self.senderTextField.text = @"";
        self.pwdTextField.text = @"";
        self.smtpTextField.text = self.emailArray[0];//SMTP服务器
        self.smtpServer = self.smtpServerArray[0];//SMTP服务器
        self.smtpPort = self.smtpPortArray[0];//SMTP端口
        
        //隐藏、显示pwdPromptLabel或解除绑定按钮，相关view位置的调整
        [self hiddenPwdPromptLabel:YES unbindButton:YES pwdPromptLabelText:@""];
    }
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    if (self.isIndicatorCancelled) {
        return;//YES表示取消保存或解除时的指示器，并不接收设备返回的任何数据
    }
    self.isCommandSentOk = YES;
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
            
        case RET_SET_ALARM_EMAIL:
        {
            
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0){
                
                if(self.alarmSettingController.isSMTP == 0){//只支持系统默认邮箱(旧设备)
                    
                    if (self.isUnbindEmail) {
                        self.isUnbindEmail = NO;
                    }
                    
                    //YES表示返回上个界面，重新获取报警邮箱信息，进行更新
                    self.alarmSettingController.isRefreshAlarmEmail = YES;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.progressAlert hide:YES];
                        [self.maskLayerView setHidden:YES];
                        [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            usleep(800000);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self onBackPress];
                            });
                        });
                    });
                }else{//既支持系统默认邮箱(去掉系统默认)，又支持非系统默认邮箱(新设备)
                    if (self.isUnbindEmail) {
                        self.isUnbindEmail = NO;
                        
                        //YES表示返回上个界面，重新获取报警邮箱信息，进行更新
                        self.alarmSettingController.isRefreshAlarmEmail = YES;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.progressAlert hide:YES];
                            [self.maskLayerView setHidden:YES];
                            [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                usleep(800000);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self onBackPress];
                                });
                            });
                        });
                    }else{
                        //设置成功时，再次获取SMTP数据，取出邮箱密码，判断是否正确
                        //正确，则返回上一界面；错误，则在当前界面提示密码错误
                        dispatch_async(dispatch_get_main_queue(), ^{
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                usleep(3000000);//延时3秒，再获取
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    self.isCommandSentOk = NO;
                                    _getCounts = 1;
                                    [[P2PClient sharedClient] getAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword];
                                });
                            });
                        });
                    }
                }
                
            }else if(result==15){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.maskLayerView setHidden:YES];
                    [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.maskLayerView setHidden:YES];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_ALARM_EMAIL:
        {
            int isRightPwd = [[parameter valueForKey:@"isRightPwd"] intValue];
            int isEmailVerified = [[parameter valueForKey:@"isEmailVerified"] intValue];
            
            
            if (isEmailVerified == 1) {
                if (_getCounts < 5) {
                    _getCounts++;
                    
                    //如果邮箱未验证，则再次获取邮箱信息；
                    dispatch_async(dispatch_get_main_queue(), ^{
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            usleep(3000000);//延时3秒，再获取
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.isCommandSentOk = NO;
                                [[P2PClient sharedClient] getAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword];
                            });
                        });
                    });
                }else{//如果获取了5次，邮箱还是未验证，则不再获取，提示邮箱未验证
                    
                    //YES表示返回上个界面，重新获取报警邮箱信息，进行更新
                    self.alarmSettingController.isNotVerifiedEmail = YES;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.progressAlert hide:YES];
                        [self.maskLayerView setHidden:YES];
                        [self.view makeToast:NSLocalizedString(@"not_verified", nil)];
                        self.pwdPromptLabel.text = NSLocalizedString(@"not_verified", nil);
                        if (_isManual) {
                            //隐藏、显示m_encryptView、pwdPromptLabel或解除绑定按钮，相关view位置的调整
                            self.m_isHiddenPwdPromptLabel = NO;
                            self.m_pwdPromptLabelText = NSLocalizedString(@"not_verified", nil);
                            self.m_isHiddenUnbindButton = NO;
                            [self manualViewHiddenEncryptView:self.m_isHiddenEncryptView hiddenPwdPromptLabel:self.m_isHiddenPwdPromptLabel hiddenUnbindButton:self.m_isHiddenUnbindButton pwdPromptLabelText:self.m_pwdPromptLabelText];
                        }else{
                            //隐藏、显示pwdPromptLabel或解除绑定按钮，相关view位置的调整
                            [self hiddenPwdPromptLabel:NO unbindButton:NO pwdPromptLabelText:NSLocalizedString(@"not_verified", nil)];
                        }
                        
                    });
                }
            }else{
                //YES表示返回上个界面，重新获取报警邮箱信息，进行更新
                self.alarmSettingController.isRefreshAlarmEmail = YES;
                
                if (isRightPwd == 0) {//错误，则在当前界面提示密码错误
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.progressAlert hide:YES];
                        [self.maskLayerView setHidden:YES];
                        
                        if (_isManual) {
                            [self.view makeToast:NSLocalizedString(@"pwd_smtp_error", nil)];
                            
                            //隐藏、显示m_encryptView、pwdPromptLabel或解除绑定按钮，相关view位置的调整
                            self.m_isHiddenPwdPromptLabel = NO;
                            self.m_pwdPromptLabelText = NSLocalizedString(@"pwd_smtp_error", nil);
                            self.m_isHiddenUnbindButton = NO;
                            [self manualViewHiddenEncryptView:self.m_isHiddenEncryptView hiddenPwdPromptLabel:self.m_isHiddenPwdPromptLabel hiddenUnbindButton:self.m_isHiddenUnbindButton pwdPromptLabelText:self.m_pwdPromptLabelText];
                            
                        }else{
                            [self.view makeToast:NSLocalizedString(@"pwd_error", nil)];
                            self.pwdPromptLabel.text = NSLocalizedString(@"pwd_error", nil);
                            
                            //隐藏、显示pwdPromptLabel或解除绑定按钮，相关view位置的调整
                            [self hiddenPwdPromptLabel:NO unbindButton:NO pwdPromptLabelText:NSLocalizedString(@"pwd_error", nil)];
                        }
                    });
                }else{//正确，则返回上一界面
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.progressAlert hide:YES];
                        [self.maskLayerView setHidden:YES];
                        [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            usleep(800000);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self onBackPress];
                            });
                        });
                    });
                }
            }
        }
            break;
            
        case RET_DEVICE_NOT_SUPPORT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.progressAlert hide:YES];
                [self.maskLayerView setHidden:YES];
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
    if (self.isCommandSentOk) {
        return;//YES表示APP发送set/get命令成功，ack_receiveRemoteMessage里不用做任何处理
    }
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
        case ACK_RET_SET_ALARM_EMAIL:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.maskLayerView setHidden:YES];
                    [self.view makeToast:NSLocalizedString(@"original_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend set alarm email");
                    
                    
                    if (self.alarmSettingController.isSMTP == 0) {
                        if(self.isUnbindEmail){//清除收件人
                            
                            [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:@"0" smtpServer:@"" smtpPort:0 smtpUser:@"" smtpPwd:@"" encryptType:self.m_encryptType subject:@"" content:@"" isSupportSMTP:NO];
                        }else{
                            
                            [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:self.field1.text smtpServer:@"" smtpPort:0 smtpUser:@"" smtpPwd:@"" encryptType:self.m_encryptType subject:@"" content:@"" isSupportSMTP:NO];
                        }
                    }else{
                        if(self.isUnbindEmail){//清除收件人
                            [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:@"0" smtpServer:@"" smtpPort:0 smtpUser:@"0" smtpPwd:@"" encryptType:self.m_encryptType subject:@"" content:@"" isSupportSMTP:YES];
                            
                        }else{
                            NSString *smtpServer = self.smtpServer;//SMTP服务器
                            int smtpPort = [self.smtpPort intValue];//SMTP端口
                            NSString *senderEmail = [NSString stringWithFormat:@"%@%@",self.senderTextField.text,self.smtpTextField.text];//发件人
                            NSString *senderPwd = self.pwdTextField.text;//发件密码
                            NSString *reciEmail = senderEmail;//收件人
                            
                            [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:reciEmail smtpServer:smtpServer smtpPort:smtpPort smtpUser:senderEmail smtpPwd:senderPwd encryptType:self.m_encryptType subject:self.subjectTextView.text content:self.contentTextView.text isSupportSMTP:YES];
                        }
                    }
                }
                
                
            });
            
        }
            break;
        case ACK_RET_GET_ALARM_EMAIL:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.maskLayerView setHidden:YES];
                    [self.view makeToast:NSLocalizedString(@"original_password_error", nil)];
                }else if(result==2){
                    DLog(@"resend get alarm email");
                    [[P2PClient sharedClient] getAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
        }
            break;
            
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.smtpServerArray = @[@"smtp.163.com",@"smtp.qq.com",@"smtp.sina.com.cn",@"smtp.mail.yahoo.com",@"173.194.193.108,173.194.67.108,smtp.gmail.com",@"smtp.189.cn",@"smtp.live.com"];
    self.smtpPortArray = @[@"25",@"25",@"25",@"587",@"465",@"25",@"587"];
    self.emailArray = @[@"@163.com",@"@qq.com",@"@sina.com",@"@yahoo.com",@"@gmail.com",@"@189.cn",@"@hotmail.com"];
    self.m_portArray = @[NSLocalizedString(@"non_encrypted", nil),NSLocalizedString(@"465(SSL)", nil),NSLocalizedString(@"587(TLS)", nil),NSLocalizedString(@"custom", nil)];
    [self initComponent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define MARGIN_LEFT_RIGHT 5.0
-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    
    
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    [topBar setRightButtonText:NSLocalizedString(@"save", nil)];
    [topBar.rightButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"bind_email",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    
    //email新调整
    if(self.alarmSettingController.isSMTP == 0){
        //只支持系统默认邮箱(旧设备)的界面初始化
        [self initComponentOfSystemDefaultEmail:width height:height];
    }else{
        //既支持系统默认邮箱(去掉系统默认)，又支持非系统默认邮箱(新设备)
        //不可以手动配置的界面初始化（默认显示）
        [self initComponentDefault:width height:height];
    }
    
    
    
    //指示器
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    self.progressAlert.labelText = NSLocalizedString(@"validating",nil);
    [self.view addSubview:self.progressAlert];
    
    
    
    //添加手势，点击view时，取消旋转提示
    UIView *maskLayerView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    UITapGestureRecognizer *singleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    [singleTapG setNumberOfTapsRequired:1];
    [maskLayerView addGestureRecognizer:singleTapG];
    [self.view addSubview:maskLayerView];
    [maskLayerView setHidden:YES];
    self.maskLayerView = maskLayerView;
    [maskLayerView release];
    [singleTapG release];
}

#pragma mark - 只支持系统默认邮箱(旧设备)的界面初始化
-(void)initComponentOfSystemDefaultEmail:(CGFloat)width height:(CGFloat)height{
    //报警邮箱（系统默认）
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, NAVIGATION_BAR_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
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
    self.field1 = field1;
    field1.delegate = self;
    [self.view addSubview:field1];
    [field1 release];
    
    //解除绑定按钮
    UIButton *unbindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [unbindButton setFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.field1.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, 34)];
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
}

#pragma mark - 既支持系统默认邮箱(去掉系统默认)，又支持非系统默认邮箱(新设备)
#pragma mark 不可以手动配置的界面初始化
-(void)hiddenInitComponentDefautl:(BOOL)isHiddenDefaultView{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    /*
     *1. 如果用户选择了手动配置邮箱绑定时，则隐藏默认界面defaultView
     *2. 显示手动配置界面manualView
     */
    if (isHiddenDefaultView) {
        [self.defaultView setHidden:YES];
        //可以手动配置的界面初始化（默认隐藏）
        [self initComponentManual:width height:height];
    }else{
        [self.manualView removeFromSuperview];
        [self.defaultView setHidden:NO];
    }
}
-(void)initComponentDefault:(CGFloat)width height:(CGFloat)height{
    //默认view（非手动配置）
    UIView *defaultView = [[UIView alloc] initWithFrame:CGRectMake(0.0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    defaultView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:defaultView];
    self.defaultView = defaultView;
    [defaultView release];
    
    //发件人
    UITextField *senderTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, 20.0, width-MARGIN_LEFT_RIGHT*2-140.0, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        senderTextField.layer.borderWidth = 1;
        senderTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        senderTextField.layer.cornerRadius = 5.0;
    }
    senderTextField.textAlignment = NSTextAlignmentLeft;
    senderTextField.placeholder = NSLocalizedString(@"input_email", nil);
    senderTextField.font = XFontBold_16;
    senderTextField.borderStyle = UITextBorderStyleRoundedRect;
    senderTextField.returnKeyType = UIReturnKeyDone;
    senderTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    senderTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.defaultView addSubview:senderTextField];
    //左边的view
    CGFloat senderLeftLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"mailbox", nil) font:XFontBold_16 maxWidth:width];
    UILabel *senderLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, senderLeftLabelWidth+5.0, TEXT_FIELD_HEIGHT)];
    senderLeftLabel.backgroundColor = [UIColor clearColor];
    senderLeftLabel.text = NSLocalizedString(@"mailbox", nil);
    senderLeftLabel.textAlignment = NSTextAlignmentRight;
    senderLeftLabel.font = XFontBold_16;
    senderTextField.leftView = senderLeftLabel;
    senderTextField.leftViewMode = UITextFieldViewModeAlways;
    [senderLeftLabel release];
    senderTextField.delegate = self;
    self.senderTextField = senderTextField;
    [senderTextField release];
    
    //发件人邮局
    UITextField *smtpTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.senderTextField.frame.origin.x+self.senderTextField.frame.size.width+5.0, 20.0, 140.0-5.0, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        smtpTextField.layer.borderWidth = 1;
        smtpTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        smtpTextField.layer.cornerRadius = 5.0;
    }
    smtpTextField.userInteractionEnabled = NO;
    smtpTextField.font = XFontBold_16;
    smtpTextField.textAlignment = NSTextAlignmentLeft;
    smtpTextField.borderStyle = UITextBorderStyleRoundedRect;
    smtpTextField.returnKeyType = UIReturnKeyDone;
    smtpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    smtpTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    smtpTextField.text = self.emailArray[0];
    [self.defaultView addSubview:smtpTextField];
    self.smtpTextField = smtpTextField;
    [smtpTextField release];
    //下拉按钮
    UIButton *dropDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dropDownBtn.frame = CGRectMake(width-MARGIN_LEFT_RIGHT-TEXT_FIELD_HEIGHT, 20.0, TEXT_FIELD_HEIGHT, TEXT_FIELD_HEIGHT);
    dropDownBtn.tag = 21;
    [dropDownBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    [dropDownBtn addTarget:self action:@selector(changeOpenStatus:) forControlEvents:UIControlEventTouchUpInside];
    [self.defaultView addSubview:dropDownBtn];
    self.dropDownBtn = dropDownBtn;
    //下拉表格
    TableViewWithBlock *tableView = [[TableViewWithBlock alloc] initWithFrame:CGRectMake(self.smtpTextField.frame.origin.x, self.smtpTextField.frame.origin.y+TEXT_FIELD_HEIGHT, self.smtpTextField.frame.size.width, 0) style:UITableViewStylePlain];
    [self.defaultView addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    [self.tableView initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        return (NSInteger)self.emailArray.count;//多少行
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        //生成cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectionCell"] autorelease];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        
        [cell.textLabel setText:self.emailArray[indexPath.row]];
        [cell.textLabel setFont:XFontBold_16];
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        //选中cell回调
        UITableViewCell *cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        self.smtpTextField.text=cell.textLabel.text;
        self.smtpServer = self.smtpServerArray[indexPath.row];//SMTP服务器
        self.smtpPort = self.smtpPortArray[indexPath.row];//SMTP端口
        
        [self.dropDownBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.tableView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.tableView.layer setBorderWidth:1.0];
    
    //邮箱密码
    UITextField *pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.senderTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        pwdTextField.layer.borderWidth = 1;
        pwdTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        pwdTextField.layer.cornerRadius = 5.0;
    }
    pwdTextField.textAlignment = NSTextAlignmentLeft;
    pwdTextField.placeholder = NSLocalizedString(@"input_password", nil);
    pwdTextField.font = XFontBold_16;
    pwdTextField.borderStyle = UITextBorderStyleRoundedRect;
    pwdTextField.returnKeyType = UIReturnKeyDone;
    pwdTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    pwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    pwdTextField.secureTextEntry = YES;
    [self.defaultView addSubview:pwdTextField];
    //左边的view
    CGFloat pwdLeftLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"password", nil) font:XFontBold_16 maxWidth:width];
    UILabel *pwdLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, pwdLeftLabelWidth+5.0, TEXT_FIELD_HEIGHT)];
    pwdLeftLabel.backgroundColor = [UIColor clearColor];
    pwdLeftLabel.text = NSLocalizedString(@"password", nil);
    pwdLeftLabel.textAlignment = NSTextAlignmentRight;
    pwdLeftLabel.font = XFontBold_16;
    pwdTextField.leftView = pwdLeftLabel;
    pwdTextField.leftViewMode = UITextFieldViewModeAlways;
    [pwdLeftLabel release];
    pwdTextField.delegate = self;
    self.pwdTextField = pwdTextField;
    [pwdTextField release];
    
    //邮箱密码错误提示或邮箱未验证
    UILabel *pwdPromptLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT*2, self.pwdTextField.frame.origin.y+TEXT_FIELD_HEIGHT, width-MARGIN_LEFT_RIGHT*4, TEXT_FIELD_HEIGHT)];
    pwdPromptLabel.backgroundColor = [UIColor clearColor];
    pwdPromptLabel.text = @"";
    pwdPromptLabel.numberOfLines = 0;
    pwdPromptLabel.font = XFontBold_16;
    pwdPromptLabel.textColor = [UIColor redColor];
    [self.defaultView addSubview:pwdPromptLabel];
    [pwdPromptLabel setHidden:YES];//隐藏
    self.pwdPromptLabel = pwdPromptLabel;
    [pwdPromptLabel release];
    
    //解除绑定按钮
    UIButton *unbindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [unbindButton setFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.pwdPromptLabel.frame.origin.y+TEXT_FIELD_HEIGHT+10, width-MARGIN_LEFT_RIGHT*2, 34)];
    UIImage *unbindButtonImage = [UIImage imageNamed:@"bg_blue_button"];
    UIImage *unbindButtonImage_p = [UIImage imageNamed:@"bg_blue_button_p"];
    unbindButtonImage = [unbindButtonImage stretchableImageWithLeftCapWidth:unbindButtonImage.size.width*0.5 topCapHeight:unbindButtonImage.size.height*0.5];
    unbindButtonImage_p = [unbindButtonImage_p stretchableImageWithLeftCapWidth:unbindButtonImage_p.size.width*0.5 topCapHeight:unbindButtonImage_p.size.height*0.5];
    [unbindButton setBackgroundImage:unbindButtonImage forState:UIControlStateNormal];
    [unbindButton setBackgroundImage:unbindButtonImage_p forState:UIControlStateHighlighted];
    [unbindButton addTarget:self action:@selector(onUnbindEmail) forControlEvents:UIControlEventTouchUpInside];
    [unbindButton setTitle:NSLocalizedString(@"unbind_email", nil) forState:UIControlStateNormal];
    [self.defaultView addSubview:unbindButton];
    [unbindButton setHidden:YES];//隐藏
    self.unbindButton = unbindButton;
    
    //手动配置
    CGFloat sltBtnWH = 25.0;
    CGFloat manualLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"manual_setting", nil) font:XFontBold_16 maxWidth:width];
    UIView *d_manualBtnView = [[UIView alloc] initWithFrame:CGRectMake(width-MARGIN_LEFT_RIGHT*2-manualLabelWidth-sltBtnWH-5.0, self.pwdTextField.frame.origin.y+self.pwdTextField.frame.size.height+10.0, manualLabelWidth+sltBtnWH+5.0, sltBtnWH)];
    d_manualBtnView.backgroundColor = [UIColor clearColor];
    [self.defaultView addSubview:d_manualBtnView];
    self.d_manualBtnView = d_manualBtnView;
    [d_manualBtnView release];
    //手动配置文本
    UILabel *manualLabel = [[UILabel alloc] initWithFrame:CGRectMake(sltBtnWH+5.0, 0.0, manualLabelWidth, sltBtnWH)];
    manualLabel.backgroundColor = [UIColor clearColor];
    manualLabel.text = NSLocalizedString(@"manual_setting", nil);
    manualLabel.numberOfLines = 0;
    manualLabel.font = XFontBold_16;
    manualLabel.textColor = [UIColor lightGrayColor];
    [self.d_manualBtnView addSubview:manualLabel];
    [manualLabel release];
    
    //手动配置按钮
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(0.0, 0.0, sltBtnWH, sltBtnWH);
    [selectBtn setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(btnClickToSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.d_manualBtnView addSubview:selectBtn];
    
    //Email主题
    UITextView *subjectTextView = [[UITextView alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.pwdTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, 50)];
    if(CURRENT_VERSION>=7.0){
        subjectTextView.layer.borderWidth = 1;
        subjectTextView.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        subjectTextView.layer.cornerRadius = 5.0;
    }
    subjectTextView.delegate = self;
    subjectTextView.returnKeyType = UIReturnKeyDone;//返回键的类型
    [subjectTextView setFont:XFontBold_16];
    self.subjectTextView.text = @"";
    //    [self.defaultView addSubview:subjectTextView];
    self.subjectTextView = subjectTextView;
    [subjectTextView release];
    
    //Email内容
    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.subjectTextView.frame.origin.y+self.subjectTextView.frame.size.height+20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT*2)];
    if(CURRENT_VERSION>=7.0){
        contentTextView.layer.borderWidth = 1;
        contentTextView.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        contentTextView.layer.cornerRadius = 5.0;
    }
    contentTextView.delegate = self;
    contentTextView.returnKeyType = UIReturnKeyDone;//返回键的类型
    [contentTextView setFont:XFontBold_16];
    self.contentTextView.text = @"";
    //    [self.defaultView addSubview:contentTextView];
    self.contentTextView = contentTextView;
    [contentTextView release];
    
    [self.defaultView bringSubviewToFront:self.tableView];
}

#pragma mark - 既支持系统默认邮箱(去掉系统默认)，又支持非系统默认邮箱(新设备)
#pragma mark 可以手动配置的界面初始化
-(void)initComponentManual:(CGFloat)width height:(CGFloat)height{
    //手动配置view
    UIScrollView *manualView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    manualView.backgroundColor = [UIColor clearColor];
    manualView.showsVerticalScrollIndicator = NO;
    [manualView setContentSize:CGSizeMake(width, 568.0)];
    [self.view addSubview:manualView];
    self.manualView = manualView;
    [manualView release];
    
    //收件箱
    UITextField *m_receiverTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, 20.0, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        m_receiverTextField.layer.borderWidth = 1;
        m_receiverTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        m_receiverTextField.layer.cornerRadius = 5.0;
    }
    m_receiverTextField.textAlignment = NSTextAlignmentLeft;
    m_receiverTextField.placeholder = NSLocalizedString(@"recipient_number", nil);
    m_receiverTextField.font = XFontBold_16;
    m_receiverTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_receiverTextField.returnKeyType = UIReturnKeyDone;
    m_receiverTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_receiverTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.manualView addSubview:m_receiverTextField];
    //左边的view
    CGFloat m_receiverLeftLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"recipient", nil) font:XFontBold_16 maxWidth:width];
    UILabel *m_receiverLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, m_receiverLeftLabelWidth+5.0, TEXT_FIELD_HEIGHT)];
    m_receiverLeftLabel.backgroundColor = [UIColor clearColor];
    m_receiverLeftLabel.text = NSLocalizedString(@"recipient", nil);
    m_receiverLeftLabel.textAlignment = NSTextAlignmentRight;
    m_receiverLeftLabel.font = XFontBold_16;
    m_receiverTextField.leftView = m_receiverLeftLabel;
    m_receiverTextField.leftViewMode = UITextFieldViewModeAlways;
    [m_receiverLeftLabel release];
    m_receiverTextField.delegate = self;
    self.m_receiverTextField = m_receiverTextField;
    [m_receiverTextField release];
    
    //收件箱与发件箱分隔线
    //实线
    //    UIView *m_lineView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.m_receiverTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20.0, width-MARGIN_LEFT_RIGHT*2, 1.0)];
    //    m_lineView.backgroundColor = [UIColor lightGrayColor];
    //    [self.manualView addSubview:m_lineView];
    //    [m_lineView release];
    //虚线
    UIImageView *m_lineView = [[UIImageView alloc]initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.m_receiverTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20.0, width-MARGIN_LEFT_RIGHT*2, 1.0)];
    [self.manualView addSubview:m_lineView];
    
    UIGraphicsBeginImageContext(m_lineView.frame.size);   //开始画线
    [m_lineView.image drawInRect:CGRectMake(0, 0, m_lineView.frame.size.width, m_lineView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
    
    float lengths[] = {5,5};//元素1表示要画的长度；元素2表示要跳过的长度
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, [UIColor lightGrayColor].CGColor);
    CGContextSetLineDash(line, 0, lengths, 2);  //画虚线
    CGContextMoveToPoint(line, 0.0, m_lineView.frame.size.height/2.0);    //开始画线
    CGContextAddLineToPoint(line, m_lineView.frame.size.width, m_lineView.frame.size.height/2.0);
    CGContextStrokePath(line);
    
    m_lineView.image = UIGraphicsGetImageFromCurrentImageContext();
    [m_lineView release];
    
    //发件箱
    UITextField *m_senderTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, m_lineView.frame.origin.y+1.0+20.0, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        m_senderTextField.layer.borderWidth = 1;
        m_senderTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        m_senderTextField.layer.cornerRadius = 5.0;
    }
    m_senderTextField.textAlignment = NSTextAlignmentLeft;
    m_senderTextField.placeholder = NSLocalizedString(@"input_sender", nil);
    m_senderTextField.font = XFontBold_16;
    m_senderTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_senderTextField.returnKeyType = UIReturnKeyDone;
    m_senderTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_senderTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.manualView addSubview:m_senderTextField];
    //左边的view
    CGFloat m_senderLeftLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"sender", nil) font:XFontBold_16 maxWidth:width];
    UILabel *m_senderLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, m_senderLeftLabelWidth+5.0, TEXT_FIELD_HEIGHT)];
    m_senderLeftLabel.backgroundColor = [UIColor clearColor];
    m_senderLeftLabel.text = NSLocalizedString(@"sender", nil);
    m_senderLeftLabel.textAlignment = NSTextAlignmentRight;
    m_senderLeftLabel.font = XFontBold_16;
    m_senderTextField.leftView = m_senderLeftLabel;
    m_senderTextField.leftViewMode = UITextFieldViewModeAlways;
    [m_senderLeftLabel release];
    m_senderTextField.delegate = self;
    self.m_senderTextField = m_senderTextField;
    [m_senderTextField release];
    
    //smtp地址
    UITextField *m_smtpTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.m_senderTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        m_smtpTextField.layer.borderWidth = 1;
        m_smtpTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        m_smtpTextField.layer.cornerRadius = 5.0;
    }
    m_smtpTextField.textAlignment = NSTextAlignmentLeft;
    m_smtpTextField.placeholder = NSLocalizedString(@"smtp_number", nil);
    m_smtpTextField.font = XFontBold_16;
    m_smtpTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_smtpTextField.returnKeyType = UIReturnKeyDone;
    m_smtpTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    m_smtpTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.manualView addSubview:m_smtpTextField];
    //左边的view
    CGFloat m_smtpLeftLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"smtp_address", nil) font:XFontBold_16 maxWidth:width];
    UILabel *m_smtpLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, m_smtpLeftLabelWidth+5.0, TEXT_FIELD_HEIGHT)];
    m_smtpLeftLabel.backgroundColor = [UIColor clearColor];
    m_smtpLeftLabel.text = NSLocalizedString(@"smtp_address", nil);
    m_smtpLeftLabel.textAlignment = NSTextAlignmentRight;
    m_smtpLeftLabel.font = XFontBold_16;
    m_smtpTextField.leftView = m_smtpLeftLabel;
    m_smtpTextField.leftViewMode = UITextFieldViewModeAlways;
    [m_smtpLeftLabel release];
    m_smtpTextField.delegate = self;
    self.m_smtpTextField = m_smtpTextField;
    [m_smtpTextField release];
    
    //端口
    UITextField *m_portTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.m_smtpTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        m_portTextField.layer.borderWidth = 1;
        m_portTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        m_portTextField.layer.cornerRadius = 5.0;
    }
    m_portTextField.userInteractionEnabled = NO;//默认不可编辑，选择自定义端口时，可编辑
    m_portTextField.textAlignment = NSTextAlignmentLeft;
    m_portTextField.placeholder = NSLocalizedString(@"input_port", nil);
    m_portTextField.font = XFontBold_16;
    m_portTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_portTextField.returnKeyType = UIReturnKeyDone;
    m_portTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    m_portTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.manualView addSubview:m_portTextField];
    //左边的view
    CGFloat m_portLeftLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"port", nil) font:XFontBold_16 maxWidth:width];
    UILabel *m_portLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, m_portLeftLabelWidth+5.0, TEXT_FIELD_HEIGHT)];
    m_portLeftLabel.backgroundColor = [UIColor clearColor];
    m_portLeftLabel.text = NSLocalizedString(@"port", nil);
    m_portLeftLabel.textAlignment = NSTextAlignmentRight;
    m_portLeftLabel.font = XFontBold_16;
    m_portTextField.leftView = m_portLeftLabel;
    m_portTextField.leftViewMode = UITextFieldViewModeAlways;
    [m_portLeftLabel release];
    m_portTextField.delegate = self;
    self.m_portTextField = m_portTextField;
    [m_portTextField release];
    //下拉按钮
    UIButton *m_dropDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    m_dropDownBtn.frame = CGRectMake(width-MARGIN_LEFT_RIGHT-TEXT_FIELD_HEIGHT, self.m_smtpTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20, TEXT_FIELD_HEIGHT, TEXT_FIELD_HEIGHT);
    m_dropDownBtn.tag = 20;
    [m_dropDownBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    [m_dropDownBtn addTarget:self action:@selector(changeOpenStatus:) forControlEvents:UIControlEventTouchUpInside];
    [self.manualView addSubview:m_dropDownBtn];
    self.m_dropDownBtn = m_dropDownBtn;
    //下拉表格
    TableViewWithBlock *m_tableView = [[TableViewWithBlock alloc] initWithFrame:CGRectMake(self.m_portTextField.frame.size.width-135.0, self.m_portTextField.frame.origin.y+TEXT_FIELD_HEIGHT, 135.0, 0.0) style:UITableViewStylePlain];
    [self.manualView addSubview:m_tableView];
    self.m_tableView = m_tableView;
    [m_tableView release];
    [self.m_tableView initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        return (NSInteger)self.m_portArray.count;//多少行;//多少行
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        //生成cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PortCell"];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PortCell"] autorelease];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        
        [cell.textLabel setText:self.m_portArray[indexPath.row]];
        [cell.textLabel setFont:XFontBold_16];
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        //选中cell回调
        
        /*
         *1. 选择smtp端口
         *2. 选择加密方式
         *3. 若选择自定义端口，则显示加密方式框；否则隐藏
         */
        self.m_portTextField.userInteractionEnabled = NO;//默认不可编辑，选择自定义端口时，可编辑
        if (indexPath.row == 0) {
            m_portTextField.text = @"25";
            self.m_encryptType = 0;
            self.m_isHiddenEncryptView = YES;
            [self manualViewHiddenEncryptView:self.m_isHiddenEncryptView hiddenPwdPromptLabel:self.m_isHiddenPwdPromptLabel hiddenUnbindButton:self.m_isHiddenUnbindButton pwdPromptLabelText:self.m_pwdPromptLabelText];
        }else if (indexPath.row == 1){
            m_portTextField.text = @"465";
            self.m_encryptType = 1;
            self.m_isHiddenEncryptView = YES;
            [self manualViewHiddenEncryptView:self.m_isHiddenEncryptView hiddenPwdPromptLabel:self.m_isHiddenPwdPromptLabel hiddenUnbindButton:self.m_isHiddenUnbindButton pwdPromptLabelText:self.m_pwdPromptLabelText];
        }else if (indexPath.row == 2){
            m_portTextField.text = @"587";
            self.m_encryptType = 2;
            self.m_isHiddenEncryptView = YES;
            [self manualViewHiddenEncryptView:self.m_isHiddenEncryptView hiddenPwdPromptLabel:self.m_isHiddenPwdPromptLabel hiddenUnbindButton:self.m_isHiddenUnbindButton pwdPromptLabelText:self.m_pwdPromptLabelText];
        }else{//自定义端口
            m_portTextField.text = @"";
            self.m_encryptType = 0;
            self.m_portTextField.userInteractionEnabled = YES;//默认不可编辑，选择自定义端口时，可编辑
            self.m_isHiddenEncryptView = NO;
            [self manualViewHiddenEncryptView:self.m_isHiddenEncryptView hiddenPwdPromptLabel:self.m_isHiddenPwdPromptLabel hiddenUnbindButton:self.m_isHiddenUnbindButton pwdPromptLabelText:self.m_pwdPromptLabelText];
        }
        
        
        [self.m_dropDownBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
    [self.m_tableView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.m_tableView.layer setBorderWidth:1.0];
    
    //发件箱密码
    UITextField *m_pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.m_portTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        m_pwdTextField.layer.borderWidth = 1;
        m_pwdTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        m_pwdTextField.layer.cornerRadius = 5.0;
    }
    m_pwdTextField.textAlignment = NSTextAlignmentLeft;
    m_pwdTextField.placeholder = NSLocalizedString(@"input_password", nil);
    m_pwdTextField.font = XFontBold_16;
    m_pwdTextField.borderStyle = UITextBorderStyleRoundedRect;
    m_pwdTextField.returnKeyType = UIReturnKeyDone;
    m_pwdTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    m_pwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_pwdTextField.secureTextEntry = YES;
    [self.manualView addSubview:m_pwdTextField];
    //左边的view
    CGFloat m_pwdLeftLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"password", nil) font:XFontBold_16 maxWidth:width];
    UILabel *m_pwdLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, m_pwdLeftLabelWidth+5.0, TEXT_FIELD_HEIGHT)];
    m_pwdLeftLabel.backgroundColor = [UIColor clearColor];
    m_pwdLeftLabel.text = NSLocalizedString(@"password", nil);
    m_pwdLeftLabel.textAlignment = NSTextAlignmentRight;
    m_pwdLeftLabel.font = XFontBold_16;
    m_pwdTextField.leftView = m_pwdLeftLabel;
    m_pwdTextField.leftViewMode = UITextFieldViewModeAlways;
    [m_pwdLeftLabel release];
    m_pwdTextField.delegate = self;
    self.m_pwdTextField = m_pwdTextField;
    [m_pwdTextField release];
    
    //加密方式
    //背景框
    UITextField *m_encryptBgView = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.m_pwdTextField.frame.origin.y+TEXT_FIELD_HEIGHT+5.0, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT*2)];
    if(CURRENT_VERSION>=7.0){
        m_encryptBgView.layer.borderWidth = 1;
        m_encryptBgView.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        m_encryptBgView.layer.cornerRadius = 5.0;
    }
    m_encryptBgView.userInteractionEnabled = NO;
    m_encryptBgView.borderStyle = UITextBorderStyleRoundedRect;
    [self.manualView addSubview:m_encryptBgView];
    self.m_encryptBgView = m_encryptBgView;
    [m_encryptBgView release];
    //加密view
    UIView *m_encryptView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.m_pwdTextField.frame.origin.y+TEXT_FIELD_HEIGHT+5.0, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT*2)];
    [self.manualView addSubview:m_encryptView];
    self.m_encryptView = m_encryptView;
    [m_encryptView release];
    //加密label
    CGFloat m_labelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"encryption_mode", nil) font:XFontBold_16 maxWidth:width];
    CGFloat m_labelHeight = [Utils getStringHeightWithString:NSLocalizedString(@"encryption_mode", nil) font:XFontBold_16 maxWidth:width];
    UILabel *m_label = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, 10.0, m_labelWidth, m_labelHeight)];
    m_label.backgroundColor = [UIColor clearColor];
    m_label.text = NSLocalizedString(@"encryption_mode", nil);
    m_label.font = XFontBold_16;
    [self.m_encryptView addSubview:m_label];
    [m_label release];
    //3个加密按钮及文本
    CGFloat m_encryptBtnWH = 20.0;
    CGFloat m_space = 20.0;
    CGFloat m_encryptLabelW = 35.0;
    NSArray *m_encryptTextArr = @[NSLocalizedString(@"one_encryption", nil),NSLocalizedString(@"SSL", nil),NSLocalizedString(@"TLS", nil)];
    for (int i=0; i<3; i++) {
        UIButton *m_encryptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        m_encryptBtn.tag = 10+i;//10表示无加密；11表示SSL；12表示TLS
        m_encryptBtn.frame = CGRectMake(MARGIN_LEFT_RIGHT*4+m_space*(i+1)+i*m_encryptBtnWH+i*m_encryptLabelW, 10.0+m_labelHeight+(self.m_encryptView.frame.size.height-m_encryptBtnWH-m_labelHeight-10.0)/2, m_encryptBtnWH, m_encryptBtnWH);
        [m_encryptBtn setImage:[UIImage imageNamed:@"ic_radio_button.png"] forState:UIControlStateNormal];
        [m_encryptBtn setImage:[UIImage imageNamed:@"ic_radio_button_p.png"] forState:UIControlStateSelected];
        if (i == 0) {
            m_encryptBtn.selected = YES;//默认选择无加密方式
            //bEncryptType  0:不加密1:SSL加密 2:TLS加密
            //定义一个变量记录当前加密类型
            self.m_encryptType = 0;
        }
        [m_encryptBtn addTarget:self action:@selector(btnClickToEncrypt:) forControlEvents:UIControlEventTouchUpInside];
        [self.m_encryptView addSubview:m_encryptBtn];
        
        UILabel *m_encryptLabel = [[UILabel alloc] initWithFrame:CGRectMake(m_encryptBtn.frame.origin.x+m_encryptBtnWH+5.0, 10.0+m_labelHeight+(self.m_encryptView.frame.size.height-28.0-m_labelHeight-10.0)/2, m_encryptLabelW, 28.0)];
        m_encryptLabel.backgroundColor = [UIColor clearColor];
        m_encryptLabel.text = m_encryptTextArr[i];
        m_encryptLabel.font = XFontBold_14;
        [self.m_encryptView addSubview:m_encryptLabel];
        [m_encryptLabel release];
    }
    
    //邮箱密码错误提示或邮箱未验证
    UILabel *m_pwdPromptLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT*2, self.m_encryptView.frame.origin.y+self.m_encryptView.frame.size.height+10.0, width-MARGIN_LEFT_RIGHT*4, TEXT_FIELD_HEIGHT)];
    m_pwdPromptLabel.backgroundColor = [UIColor clearColor];
    m_pwdPromptLabel.text = @"";
    m_pwdPromptLabel.numberOfLines = 0;
    m_pwdPromptLabel.font = XFontBold_16;
    m_pwdPromptLabel.textColor = [UIColor redColor];
    [self.manualView addSubview:m_pwdPromptLabel];
    self.m_pwdPromptLabel = m_pwdPromptLabel;
    [m_pwdPromptLabel release];
    
    //解除绑定按钮
    UIButton *m_unbindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [m_unbindButton setFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.m_pwdPromptLabel.frame.origin.y+TEXT_FIELD_HEIGHT+10, width-MARGIN_LEFT_RIGHT*2, 34)];
    UIImage *m_unbindButtonImage = [UIImage imageNamed:@"bg_blue_button"];
    UIImage *m_unbindButtonImage_p = [UIImage imageNamed:@"bg_blue_button_p"];
    m_unbindButtonImage = [m_unbindButtonImage stretchableImageWithLeftCapWidth:m_unbindButtonImage.size.width*0.5 topCapHeight:m_unbindButtonImage.size.height*0.5];
    m_unbindButtonImage_p = [m_unbindButtonImage_p stretchableImageWithLeftCapWidth:m_unbindButtonImage_p.size.width*0.5 topCapHeight:m_unbindButtonImage_p.size.height*0.5];
    [m_unbindButton setBackgroundImage:m_unbindButtonImage forState:UIControlStateNormal];
    [m_unbindButton setBackgroundImage:m_unbindButtonImage_p forState:UIControlStateHighlighted];
    [m_unbindButton addTarget:self action:@selector(onUnbindEmail) forControlEvents:UIControlEventTouchUpInside];
    [m_unbindButton setTitle:NSLocalizedString(@"unbind_email", nil) forState:UIControlStateNormal];
    [self.manualView addSubview:m_unbindButton];
    self.m_unbindButton = m_unbindButton;
    
    //手动配置
    CGFloat sltBtnWH = 25.0;
    CGFloat manualLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"manual_setting", nil) font:XFontBold_16 maxWidth:width];
    UIView *m_manualBtnView = [[UIView alloc] initWithFrame:CGRectMake(width-MARGIN_LEFT_RIGHT*2-manualLabelWidth-sltBtnWH-5.0, self.m_unbindButton.frame.origin.y+self.m_unbindButton.frame.size.height+10.0, manualLabelWidth+sltBtnWH+5.0, sltBtnWH)];
    m_manualBtnView.backgroundColor = [UIColor clearColor];
    [self.manualView addSubview:m_manualBtnView];
    self.m_manualBtnView = m_manualBtnView;
    [m_manualBtnView release];
    //手动配置文本
    UILabel *manualLabel = [[UILabel alloc] initWithFrame:CGRectMake(sltBtnWH+5.0, 0.0, manualLabelWidth, sltBtnWH)];
    manualLabel.backgroundColor = [UIColor clearColor];
    manualLabel.text = NSLocalizedString(@"manual_setting", nil);
    manualLabel.numberOfLines = 0;
    manualLabel.font = XFontBold_16;
    manualLabel.textColor = XBlack;
    [self.m_manualBtnView addSubview:manualLabel];
    [manualLabel release];
    
    //手动配置按钮
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(0.0, 0.0, sltBtnWH, sltBtnWH);
    [selectBtn setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(btnClickToSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.m_manualBtnView addSubview:selectBtn];
    
    
    //Email主题
    UITextView *subjectTextView = [[UITextView alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.pwdTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, 50)];
    if(CURRENT_VERSION>=7.0){
        subjectTextView.layer.borderWidth = 1;
        subjectTextView.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        subjectTextView.layer.cornerRadius = 5.0;
    }
    subjectTextView.delegate = self;
    subjectTextView.returnKeyType = UIReturnKeyDone;//返回键的类型
    [subjectTextView setFont:XFontBold_16];
    self.subjectTextView.text = @"";
    //    [self.manualView addSubview:subjectTextView];
    [subjectTextView release];
    
    //Email内容
    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.subjectTextView.frame.origin.y+self.subjectTextView.frame.size.height+20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT*2)];
    if(CURRENT_VERSION>=7.0){
        contentTextView.layer.borderWidth = 1;
        contentTextView.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        contentTextView.layer.cornerRadius = 5.0;
    }
    contentTextView.delegate = self;
    contentTextView.returnKeyType = UIReturnKeyDone;//返回键的类型
    [contentTextView setFont:XFontBold_16];
    self.contentTextView.text = @"";
    //    [self.manualView addSubview:contentTextView];
    [contentTextView release];
    
    [self.manualView bringSubviewToFront:self.m_tableView];
    [self.view insertSubview:self.progressAlert aboveSubview:self.m_tableView];
    [self.view insertSubview:self.maskLayerView aboveSubview:self.progressAlert];
}

#pragma mark - 隐藏、显示pwdPromptLabel或解除绑定按钮，相关view位置的调整
-(void)hiddenPwdPromptLabel:(BOOL)isHiddenPwdPromptLabel unbindButton:(BOOL)isHiddenUnbindButton pwdPromptLabelText:(NSString *)pwdPromptLabelText{
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat pwdPromptLabelWidth = [Utils getStringWidthWithString:pwdPromptLabelText font:XFontBold_16 maxWidth:width];
    CGFloat pwdPromptLabelHeight = [Utils getStringHeightWithString:pwdPromptLabelText font:XFontBold_16 maxWidth:width];
    
    if (isHiddenPwdPromptLabel && isHiddenUnbindButton) {
        //都隐藏
        [self.pwdPromptLabel setHidden:YES];
        [self.unbindButton setHidden:YES];
        //调整手动配置按钮的位置
        CGRect rect3 = self.d_manualBtnView.frame;
        rect3.origin.y = self.pwdTextField.frame.origin.y+self.pwdTextField.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.d_manualBtnView.frame = rect3;
        
    }else if (isHiddenPwdPromptLabel && !isHiddenUnbindButton){
        //隐藏pwdPromptLabel，显示unbindButton
        [self.pwdPromptLabel setHidden:YES];
        [self.unbindButton setHidden:NO];
        //调整解除绑定按钮的位置
        CGRect rect2 = self.unbindButton.frame;
        rect2.origin.y = self.pwdTextField.frame.origin.y+self.pwdTextField.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.unbindButton.frame = rect2;
        //调整手动配置按钮的位置
        CGRect rect3 = self.d_manualBtnView.frame;
        rect3.origin.y = self.unbindButton.frame.origin.y+self.unbindButton.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.d_manualBtnView.frame = rect3;
        
    }else if (!isHiddenPwdPromptLabel && isHiddenUnbindButton) {
        //隐藏unbindButton，显示pwdPromptLabel
        [self.pwdPromptLabel setHidden:NO];
        [self.unbindButton setHidden:YES];
        //调整pwdPromptLabel的位置
        CGRect rect1 = self.pwdPromptLabel.frame;
        rect1.origin.y = self.pwdTextField.frame.origin.y+self.pwdTextField.frame.size.height+MARGIN_LEFT_RIGHT*2;
        rect1.size.width = pwdPromptLabelWidth;
        rect1.size.height = pwdPromptLabelHeight;
        self.pwdPromptLabel.frame = rect1;
        //调整手动配置按钮的位置
        CGRect rect3 = self.d_manualBtnView.frame;
        rect3.origin.y = self.pwdPromptLabel.frame.origin.y+self.pwdPromptLabel.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.d_manualBtnView.frame = rect3;
        
    }else{
        //都不隐藏
        [self.pwdPromptLabel setHidden:NO];
        [self.unbindButton setHidden:NO];
        //调整pwdPromptLabel的位置
        CGRect rect1 = self.pwdPromptLabel.frame;
        rect1.origin.y = self.pwdTextField.frame.origin.y+self.pwdTextField.frame.size.height+MARGIN_LEFT_RIGHT*2;
        rect1.size.width = pwdPromptLabelWidth;
        rect1.size.height = pwdPromptLabelHeight;
        self.pwdPromptLabel.frame = rect1;
        //调整解除绑定按钮的位置
        CGRect rect2 = self.unbindButton.frame;
        rect2.origin.y = self.pwdPromptLabel.frame.origin.y+self.pwdPromptLabel.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.unbindButton.frame = rect2;
        //调整手动配置按钮的位置
        CGRect rect3 = self.d_manualBtnView.frame;
        rect3.origin.y = self.unbindButton.frame.origin.y+self.unbindButton.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.d_manualBtnView.frame = rect3;
    }
}

#pragma mark - 隐藏、显示m_encryptView、pwdPromptLabel或解除绑定按钮，相关view位置的调整
-(void)manualViewHiddenEncryptView:(BOOL)isHiddenEncryptView hiddenPwdPromptLabel:(BOOL)isHiddenPwdPromptLabel hiddenUnbindButton:(BOOL)isHiddenUnbindButton pwdPromptLabelText:(NSString *)pwdPromptLabelText{
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    self.m_pwdPromptLabel.text = pwdPromptLabelText;
    CGFloat pwdPromptLabelWidth = [Utils getStringWidthWithString:pwdPromptLabelText font:XFontBold_16 maxWidth:width];
    CGFloat pwdPromptLabelHeight = [Utils getStringHeightWithString:pwdPromptLabelText font:XFontBold_16 maxWidth:width];
    
    if (!isHiddenEncryptView && !isHiddenPwdPromptLabel && !isHiddenUnbindButton) {
        //都显示
        [self.m_encryptBgView setHidden:NO];
        [self.m_encryptView setHidden:NO];
        [self.m_pwdPromptLabel setHidden:NO];
        [self.m_unbindButton setHidden:NO];
        //调整加密View的位置
        CGRect rect = self.m_encryptView.frame;
        rect.origin.y = self.m_pwdTextField.frame.origin.y+self.m_pwdTextField.frame.size.height+MARGIN_LEFT_RIGHT;
        self.m_encryptBgView.frame = rect;
        self.m_encryptView.frame = rect;
        //调整pwdPromptLabel的位置
        CGRect rect1 = self.m_pwdPromptLabel.frame;
        rect1.origin.y = self.m_encryptView.frame.origin.y+self.m_encryptView.frame.size.height+MARGIN_LEFT_RIGHT*2;
        rect1.size.width = pwdPromptLabelWidth;
        rect1.size.height = pwdPromptLabelHeight;
        self.m_pwdPromptLabel.frame = rect1;
        //调整解除绑定按钮的位置
        CGRect rect2 = self.m_unbindButton.frame;
        rect2.origin.y = self.m_pwdPromptLabel.frame.origin.y+self.m_pwdPromptLabel.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.m_unbindButton.frame = rect2;
        //调整手动配置按钮的位置
        CGRect rect3 = self.m_manualBtnView.frame;
        rect3.origin.y = self.m_unbindButton.frame.origin.y+self.m_unbindButton.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.m_manualBtnView.frame = rect3;
        
    }else if (!isHiddenEncryptView && isHiddenPwdPromptLabel && isHiddenUnbindButton){
        //隐藏PwdPromptLabel、unbindButton，显示EncryptView
        [self.m_encryptBgView setHidden:NO];
        [self.m_encryptView setHidden:NO];
        [self.m_pwdPromptLabel setHidden:YES];
        [self.m_unbindButton setHidden:YES];
        //调整加密View的位置
        CGRect rect = self.m_encryptView.frame;
        rect.origin.y = self.m_pwdTextField.frame.origin.y+self.m_pwdTextField.frame.size.height+MARGIN_LEFT_RIGHT;
        self.m_encryptBgView.frame = rect;
        self.m_encryptView.frame = rect;
        //调整手动配置按钮的位置
        CGRect rect3 = self.m_manualBtnView.frame;
        rect3.origin.y = self.m_encryptView.frame.origin.y+self.m_encryptView.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.m_manualBtnView.frame = rect3;
        
    }else if (!isHiddenEncryptView && isHiddenPwdPromptLabel && !isHiddenUnbindButton){
        //隐藏PwdPromptLabel，显示EncryptView、unbindButton
        [self.m_encryptBgView setHidden:NO];
        [self.m_encryptView setHidden:NO];
        [self.m_pwdPromptLabel setHidden:YES];
        [self.m_unbindButton setHidden:NO];
        //调整加密View的位置
        CGRect rect = self.m_encryptView.frame;
        rect.origin.y = self.m_pwdTextField.frame.origin.y+self.m_pwdTextField.frame.size.height+MARGIN_LEFT_RIGHT;
        self.m_encryptBgView.frame = rect;
        self.m_encryptView.frame = rect;
        //调整解除绑定按钮的位置
        CGRect rect2 = self.m_unbindButton.frame;
        rect2.origin.y = self.m_encryptView.frame.origin.y+self.m_encryptView.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.m_unbindButton.frame = rect2;
        //调整手动配置按钮的位置
        CGRect rect3 = self.m_manualBtnView.frame;
        rect3.origin.y = self.m_unbindButton.frame.origin.y+self.m_unbindButton.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.m_manualBtnView.frame = rect3;
        
    }else if (isHiddenEncryptView && !isHiddenPwdPromptLabel && !isHiddenUnbindButton){
        //隐藏EncryptView，显示PwdPromptLabel、unbindButton
        [self.m_encryptBgView setHidden:YES];
        [self.m_encryptView setHidden:YES];
        [self.m_pwdPromptLabel setHidden:NO];
        [self.m_unbindButton setHidden:NO];
        //调整pwdPromptLabel的位置
        CGRect rect1 = self.m_pwdPromptLabel.frame;
        rect1.origin.y = self.m_pwdTextField.frame.origin.y+self.m_pwdTextField.frame.size.height+MARGIN_LEFT_RIGHT*2;
        rect1.size.width = pwdPromptLabelWidth;
        rect1.size.height = pwdPromptLabelHeight;
        self.m_pwdPromptLabel.frame = rect1;
        //调整解除绑定按钮的位置
        CGRect rect2 = self.m_unbindButton.frame;
        rect2.origin.y = self.m_pwdPromptLabel.frame.origin.y+self.m_pwdPromptLabel.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.m_unbindButton.frame = rect2;
        //调整手动配置按钮的位置
        CGRect rect3 = self.m_manualBtnView.frame;
        rect3.origin.y = self.m_unbindButton.frame.origin.y+self.m_unbindButton.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.m_manualBtnView.frame = rect3;
        
    }else if (isHiddenEncryptView && isHiddenPwdPromptLabel && isHiddenUnbindButton){
        //都隐藏
        [self.m_encryptBgView setHidden:YES];
        [self.m_encryptView setHidden:YES];
        [self.m_pwdPromptLabel setHidden:YES];
        [self.m_unbindButton setHidden:YES];
        //调整手动配置按钮的位置
        CGRect rect3 = self.m_manualBtnView.frame;
        rect3.origin.y = self.m_pwdTextField.frame.origin.y+self.m_pwdTextField.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.m_manualBtnView.frame = rect3;
        
    }else if (isHiddenEncryptView && isHiddenPwdPromptLabel && !isHiddenUnbindButton){
        //隐藏EncryptView、PwdPromptLabel，显示unbindButton
        [self.m_encryptBgView setHidden:YES];
        [self.m_encryptView setHidden:YES];
        [self.m_pwdPromptLabel setHidden:YES];
        [self.m_unbindButton setHidden:NO];
        //调整解除绑定按钮的位置
        CGRect rect2 = self.m_unbindButton.frame;
        rect2.origin.y = self.m_pwdTextField.frame.origin.y+self.m_pwdTextField.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.m_unbindButton.frame = rect2;
        //调整手动配置按钮的位置
        CGRect rect3 = self.m_manualBtnView.frame;
        rect3.origin.y = self.m_unbindButton.frame.origin.y+self.m_unbindButton.frame.size.height+MARGIN_LEFT_RIGHT*2;
        self.m_manualBtnView.frame = rect3;
        
    }
}

#pragma mark - 手动配置与默认之间切换
-(void)btnClickToSelect:(UIButton *)button{
    _isManual = !_isManual;
    if (_isManual) {
        [self hiddenInitComponentDefautl:YES];
        if (self.isFirstInterfaceDefaultView) {
            /*
             *1. YES表示第一次进入邮箱绑定界面时，显示的界面是defaultView
             *2. 此时，切换到manualView时，初始化manualView（清空）
             */
            [self showManualViewWithInitialization:YES];
        }else{
            /*
             *1. isFirstInterfaceDefaultView为NO时，要调用
             *2. 原因是，切换到defaultView时，remove掉manualView
             *3. 而再切换回manualView时，再创建manualView
             *4. 所以要用获取到的数据再次赋值
             */
            [self showManualViewWithInitialization:NO];
        }
    }else{
        [self hiddenInitComponentDefautl:NO];
        if (!self.isFirstInterfaceDefaultView) {
            /*
             *1. NO表示第一次进入邮箱绑定界面时，显示的界面是manualView
             *2. 此时，切换到defaultView时，初始化defaultView（清空）
             */
            [self showDefaultViewWithInitialization:YES];
        }
    }
    
    /*
     *1. 手动配置与默认之间切换时，若tableView是展开的
     *2. 那么收起
     */
    if (isOpened) {
        [UIView animateWithDuration:0.3 animations:^{
            
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [self.m_dropDownBtn setImage:closeImage forState:UIControlStateNormal];
            
            CGRect m_frame=self.m_tableView.frame;
            m_frame.size.height=0.0;
            [self.m_tableView setFrame:m_frame];
        } completion:^(BOOL finished){
            isOpened=NO;
        }];
        
    }
}

#pragma mark - 选择加密类型
-(void)btnClickToEncrypt:(UIButton *)button{
    //去掉所有加密的选中状态
    for (id obj in self.m_encryptView.subviews) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *encryptBtn = (UIButton *)obj;
            encryptBtn.selected = NO;
        }
    }
    
    if (button.tag == 10) {//选择无加密方式
        //定义一个变量记录当前加密类型
        self.m_encryptType = 0;
        button.selected = YES;
    }else if (button.tag == 11){//选择SSL加密方式
        //定义一个变量记录当前加密类型
        self.m_encryptType = 1;
        button.selected = YES;
    }else{//选择TLS加密方式
        //定义一个变量记录当前加密类型
        self.m_encryptType = 2;
        button.selected = YES;
    }
}

#pragma mark - 下拉按钮触发调用函数
- (void)changeOpenStatus:(UIButton *)button {//email新调整
    if (isOpened) {
        [UIView animateWithDuration:0.3 animations:^{
            
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            if (button.tag == 20) {
                [self.m_dropDownBtn setImage:closeImage forState:UIControlStateNormal];
            }else{
                [self.dropDownBtn setImage:closeImage forState:UIControlStateNormal];
            }
            
            if (button.tag == 20) {
                CGRect m_frame=self.m_tableView.frame;
                m_frame.size.height=0.0;
                [self.m_tableView setFrame:m_frame];
            }else{
                CGRect frame=self.tableView.frame;
                frame.size.height=0.0;
                [self.tableView setFrame:frame];
            }
        } completion:^(BOOL finished){
            isOpened=NO;
        }];
        
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
            if (button.tag == 20) {
                [self.m_dropDownBtn setImage:openImage forState:UIControlStateNormal];
            }else{
                [self.dropDownBtn setImage:openImage forState:UIControlStateNormal];
            }
            
            if (button.tag == 20) {
                CGRect m_frame=self.m_tableView.frame;
                m_frame.size.height=44.0*4;
                [self.m_tableView setFrame:m_frame];
            }else{
                CGRect frame=self.tableView.frame;
                frame.size.height=200.0;
                [self.tableView setFrame:frame];
            }
        } completion:^(BOOL finished){
            isOpened=YES;
        }];
        
        
    }
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 检验IP的有效性
-(BOOL)isValidateIPAddress:(NSString *)IPAddress{
    if (!(IPAddress.length>=7 && IPAddress.length<=15)) {
        return NO;
    }
    NSArray *IPArray = [IPAddress componentsSeparatedByString:@"."];
    if (IPArray.count != 4) {//4段，即3个"."
        return NO;
    }
    for (int i = 0; i < IPArray.count; i++) {//每段是数字
        if (![IPArray[i] isValidateNumber]) {
            return NO;
        }
    }
    for (int i = 0; i < IPArray.count; i++) {//每段数字的有效范围
        if (!([IPArray[i] intValue]>=0 && [IPArray[i] intValue]<=255)) {
            return NO;
        }
    }
    
    return YES;
}

-(void)onSavePress{
    if(self.alarmSettingController.isSMTP == 0){
        //只支持系统默认邮箱的保存
        [self bindedDefaultSystemEmail];
        
    }else{
        if (_isManual) {
            //界面manualView的保存
            [self bindedNonSystemEmailInManualView];
            
        }else{
            //界面defaultView的保存
            [self bindedNonSystemEmailInDefaultView];
            
        }
    }
    
}

#pragma mark - 只支持系统默认邮箱的保存
-(void)bindedDefaultSystemEmail{
    [self.field1 resignFirstResponder];
    
    NSString *reciEmail = self.field1.text;//收件人
    
    //邮箱不可以为空
    if(!reciEmail||!reciEmail.length>0){
        [self.view makeToast:NSLocalizedString(@"input_email", nil)];
        return;
    }
    
    
    //邮箱长度应为5~31
    if(reciEmail.length<5||reciEmail.length>31){
        [self.view makeToast:NSLocalizedString(@"email_length_error", nil)];
        return;
    }
    
    //邮箱格式错误
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailFormat = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if(![emailFormat evaluateWithObject:reciEmail]){
        [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
        return;
    }
    
    
    //开始设置邮箱
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    [self.maskLayerView setHidden:NO];
    
    //YES表示取消保存或解除时的指示器，并不接收设备返回的任何数据
    self.isIndicatorCancelled = NO;
    //YES表示APP发送set/get命令成功，ack_receiveRemoteMessage里不用做任何处理
    self.isCommandSentOk = NO;
    
    
    //发件人为系统默认邮箱
    //参数bOption值为0，参数smtpServer、smtpPort、smtpUser、smtpPwd不用理会
    [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:reciEmail smtpServer:@"" smtpPort:0 smtpUser:@"" smtpPwd:@"" encryptType:self.m_encryptType subject:@"" content:@"" isSupportSMTP:NO];
}

#pragma mark - 界面defaultView的保存
-(void)bindedNonSystemEmailInDefaultView{
    [self.senderTextField resignFirstResponder];
    [self.pwdTextField resignFirstResponder];
    
    NSString *smtpServer = self.smtpServer;//SMTP服务器
    /*
     *1. 当选择smtp.gmail.com，则把smtp.gmail.com和IP以逗号隔开，赋给smtpServer
     *2. 当作参数一起发送给设备端
     */
    //email新调整
    if ([smtpServer isEqualToString:self.smtpServerArray[4]]) {
        NSLog(@"%@,192.168.1.1",smtpServer);
    }
    //return;//delete
    int smtpPort = [self.smtpPort intValue];//SMTP端口
    NSString *senderEmail = [NSString stringWithFormat:@"%@%@",self.senderTextField.text,self.smtpTextField.text];//发件人
    NSString *senderPwd = self.pwdTextField.text;//发件密码
    NSString *reciEmail = senderEmail;//收件人
    
    
    //邮箱不可以为空
    if(!self.senderTextField.text||!self.senderTextField.text.length>0){
        [self.view makeToast:NSLocalizedString(@"input_email", nil)];
        return;
    }
    
    
    //邮箱长度应为5~31
    if(reciEmail.length<5||reciEmail.length>31){
        [self.view makeToast:NSLocalizedString(@"email_length_error", nil)];
        return;
    }
    
    
    //邮箱格式错误
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailFormat = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if(![emailFormat evaluateWithObject:reciEmail]){
        [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
        return;
    }
    
    
    //密码不可以为空
    if(!senderPwd||!senderPwd.length>0){
        [self.view makeToast:NSLocalizedString(@"input_password", nil)];
        return;
    }
    
    
    //判断是否支持此邮箱,不在数组里，则表示不支持
    BOOL isIvalidEmail = YES;
    for (int i=0; i<self.emailArray.count; i++) {
        if ([self.smtpTextField.text isEqualToString:self.emailArray[i]]) {
            isIvalidEmail = NO;
            break;
        }
    }
    if (isIvalidEmail) {
        NSString *errorString = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"not_support", nil),self.smtpTextField.text];
        [self.view makeToast:errorString];
        return;
    }
    
    
    //开始设置邮箱
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    [self.maskLayerView setHidden:NO];
    
    //YES表示取消保存或解除时的指示器，并不接收设备返回的任何数据
    self.isIndicatorCancelled = NO;
    //YES表示APP发送set/get命令成功，ack_receiveRemoteMessage里不用做任何处理
    self.isCommandSentOk = NO;
    
    
    //发件人为非系统默认邮箱
    //参数bOption值为1，传入相应参数smtpServer、smtpPort、smtpUser、smtpPwd
    [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:reciEmail smtpServer:smtpServer smtpPort:smtpPort smtpUser:senderEmail smtpPwd:senderPwd encryptType:self.m_encryptType subject:self.subjectTextView.text content:self.contentTextView.text isSupportSMTP:YES];
}

#pragma mark - 界面manualView的保存
-(void)bindedNonSystemEmailInManualView{
    [self.m_receiverTextField resignFirstResponder];
    [self.m_senderTextField resignFirstResponder];
    [self.m_smtpTextField resignFirstResponder];
    [self.m_portTextField resignFirstResponder];
    [self.m_pwdTextField resignFirstResponder];
    
    
    //收件人
    NSString *reciEmail = self.m_receiverTextField.text;
    if(!reciEmail||!reciEmail.length>0){
        [self.view makeToast:NSLocalizedString(@"recipient_not_empty", nil)];
        return;
    }
    //去掉reciEmail所有空格
    reciEmail = [reciEmail stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *subEmails = [reciEmail componentsSeparatedByString:@","];
    if (subEmails.count > 3) {
        [self.view makeToast:NSLocalizedString(@"recipient_scope", nil)];
        return;
    }
    for (int i=0; i<subEmails.count; i++) {
        
        NSString * email = subEmails[i];
        //邮箱长度应为5~31
        if(email.length<5||email.length>31){
            [self.view makeToast:NSLocalizedString(@"recipient_length_format", nil)];
            return;
        }
        
        //邮箱格式错误
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailFormat = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if(![emailFormat evaluateWithObject:email]){
            [self.view makeToast:NSLocalizedString(@"recipient_format", nil)];
            return;
        }
    }
    
    //发件人
    NSString *senderEmail = self.m_senderTextField.text;
    //发件人不能为空
    if(!senderEmail||!senderEmail.length>0){
        [self.view makeToast:NSLocalizedString(@"sender_not_empty", nil)];
        return;
    }
    NSArray *subSenderEmails = [senderEmail componentsSeparatedByString:@","];
    if (subSenderEmails.count > 1) {
        [self.view makeToast:NSLocalizedString(@"sender_scope", nil)];
        return;
    }
    //邮箱长度应为5~31
    if(senderEmail.length<5||senderEmail.length>31){
        [self.view makeToast:NSLocalizedString(@"sender_length_format", nil)];
        return;
    }
    //邮箱格式错误
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailFormat = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if(![emailFormat evaluateWithObject:senderEmail]){
        [self.view makeToast:NSLocalizedString(@"sender_format", nil)];
        return;
    }
    
    //SMTP服务器
    NSString *smtpServer = self.m_smtpTextField.text;
    //SMTP服务器不可以为空
    if(!smtpServer||!smtpServer.length>0){
        [self.view makeToast:NSLocalizedString(@"smtp_not_empty", nil)];
        return;
    }
    //SMTP服务器不可以<=3
    if(smtpServer.length<=3){
        [self.view makeToast:NSLocalizedString(@"smtp_format", nil)];
        return;
    }
    //去掉smtpServer所有空格
    smtpServer = [smtpServer stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *smtpRegex = @"[a-z0-9A-Z.,]+";//smtp地址和IP地址的正则表达式为[a-z0-9A-Z.]+
    NSPredicate *smtpFormat = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", smtpRegex];
    if(![smtpFormat evaluateWithObject:smtpServer]){
        [self.view makeToast:NSLocalizedString(@"smtp_format", nil)];
        return;
    }
    NSArray *subSmtpServers = [smtpServer componentsSeparatedByString:@","];
    if (subSmtpServers.count > 5) {
        [self.view makeToast:NSLocalizedString(@"smtp_scope", nil)];
        return;
    }
    for (int i=0; i<subSmtpServers.count; i++) {
        NSArray *subComponents = [subSmtpServers[i] componentsSeparatedByString:@"."];
        if ([subComponents[0] isValidateNumber]) {//检验IP的有效性
            if (![self isValidateIPAddress:subSmtpServers[i]]) {
                [self.view makeToast:NSLocalizedString(@"smtp_format", nil)];
                return;
            }
        }
    }
    
    //SMTP端口
    //端口号不能为空
    if(!self.m_portTextField.text||!self.m_portTextField.text.length>0){
        [self.view makeToast:NSLocalizedString(@"port_not_empty", nil)];
        return;
    }
    if (![self.m_portTextField.text isValidateNumber]) {
        [self.view makeToast:NSLocalizedString(@"port_format", nil)];
        return;
    }
    int smtpPort = [self.m_portTextField.text intValue];
    if (!(smtpPort>=0 && smtpPort<=65535)) {
        [self.view makeToast:NSLocalizedString(@"port_scope", nil)];
        return;
    }
    
    //发件密码
    NSString *senderPwd = self.m_pwdTextField.text;
    //密码不可以为空
    if(!senderPwd||!senderPwd.length>0){
        [self.view makeToast:NSLocalizedString(@"input_password", nil)];
        return;
    }
    
    //加密类型
    int encryptType = self.m_encryptType;
    
    
    
    //开始设置邮箱
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    [self.maskLayerView setHidden:NO];
    
    //YES表示取消保存或解除时的指示器，并不接收设备返回的任何数据
    self.isIndicatorCancelled = NO;
    //YES表示APP发送set/get命令成功，ack_receiveRemoteMessage里不用做任何处理
    self.isCommandSentOk = NO;
    
    
    //发件人为非系统默认邮箱
    //参数bOption值为3，传入相应参数smtpServer、smtpPort、smtpUser、smtpPwd
    [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:reciEmail smtpServer:smtpServer smtpPort:smtpPort smtpUser:senderEmail smtpPwd:senderPwd encryptType:encryptType subject:self.subjectTextView.text content:self.contentTextView.text isSupportSMTP:YES];
}

-(void)onUnbindEmail{
    NSString *message = @"";
    if(self.alarmSettingController.isSMTP == 0){
        message = [NSString stringWithFormat:@"%@%@?",NSLocalizedString(@"unbind_email", nil),self.alarmSettingController.bindEmail];
        
    }else{
        if (_isManual) {
            message = [NSString stringWithFormat:@"%@%@?",NSLocalizedString(@"unbind_email", nil),self.m_receiverTextField.text];
            
        }else{
            NSString *senderEmail = [NSString stringWithFormat:@"%@%@",self.senderTextField.text,self.smtpTextField.text];//发件人
            message = [NSString stringWithFormat:@"%@%@?",NSLocalizedString(@"unbind_email", nil),senderEmail];
        }
    }
    
    
    
    UIAlertView *unBindEmailAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"unbind_email", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    [unBindEmailAlert show];
    [unBindEmailAlert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        self.isUnbindEmail = YES;
        
        self.progressAlert.dimBackground = YES;
        [self.progressAlert show:YES];
        [self.maskLayerView setHidden:NO];
        
        //YES表示取消保存或解除时的指示器，并不接收设备返回的任何数据
        self.isIndicatorCancelled = NO;
        //YES表示APP发送set/get命令成功，ack_receiveRemoteMessage里不用做任何处理
        self.isCommandSentOk = NO;
        
        if(self.alarmSettingController.isSMTP == 0){
            //发件人为系统默认邮箱
            //参数bOption值为0，参数smtpServer、smtpPort、smtpUser、smtpPwd不用理会
            [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:@"0" smtpServer:@"" smtpPort:0 smtpUser:@"" smtpPwd:@"" encryptType:self.m_encryptType subject:@"" content:@"" isSupportSMTP:NO];
        }else{
            //发件人为非系统默认邮箱
            //参数bOption值为1，传入相应参数smtpServer、smtpPort、smtpUser、smtpPwd
            [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:@"0" smtpServer:@"" smtpPort:0 smtpUser:@"0" smtpPwd:@"" encryptType:self.m_encryptType subject:@"" content:@"" isSupportSMTP:YES];
        }
    }
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{//password strength2
    //开始编辑
    
}
#pragma mark 限制收件人、发件人、SMTP地址和密码的输入的长度
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //收件人、发件人、SMTP地址和密码的输入的长度>=64时，不可输入,return NO
    if (textField == self.field1
        || textField == self.senderTextField
        || textField == self.pwdTextField
        || textField == self.m_receiverTextField
        || textField == self.m_senderTextField
        || textField == self.m_smtpTextField
        || textField == self.m_pwdTextField) {
        if (string.length == 0) return YES;//退格回删字符
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 63) {
            return NO;
        }
    }
    
    return YES;
}
#pragma mark return键
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    isTextViewOrTextField = YES;
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - 监听键盘
#pragma mark 键盘将要显示时，调用
-(UITextField *)getCurrentEditingTextField{
    //获取正处于编辑状态的UITextField
    
    if (self.senderTextField.editing) {
        return self.senderTextField;
        
    }else if (self.pwdTextField.editing){
        return self.pwdTextField;
        
    }else if (self.m_receiverTextField.editing){
        return self.m_receiverTextField;
        
    }else if (self.m_senderTextField.editing){
        return self.m_senderTextField;
        
    }else if (self.m_smtpTextField.editing){
        return self.m_smtpTextField;
        
    }else if (self.m_portTextField.editing){
        return self.m_portTextField;
        
    }else if (self.m_pwdTextField.editing){
        return self.m_pwdTextField;
        
    }else if (self.field1.editing){
        return self.field1;
        
    }
    
    
    return nil;
}
-(void)onKeyBoardWillShow:(NSNotification*)notification{//delete
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //    if (!isTextViewOrTextField) {
    //        return;
    //    }else{
    //        isTextViewOrTextField = NO;
    //    }
    
    //获取正处于编辑状态的UITextField
    UITextField *currentEditingTextField = [self getCurrentEditingTextField];
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGFloat offset1 = self.view.frame.size.height-(currentEditingTextField.frame.origin.y+currentEditingTextField.frame.size.height+NAVIGATION_BAR_HEIGHT);
                        CGFloat finalOffset;
                        if(offset1-rect.size.height<0){
                            finalOffset = rect.size.height-offset1+20;
                        }else {
                            if(offset1-rect.size.height>=20){
                                finalOffset = 0;
                            }else{
                                finalOffset = 20-(offset1-rect.size.height);
                            }
                            
                        }
                        self.view.transform = CGAffineTransformMakeTranslation(0, -finalOffset);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark 键盘将要收起时，调用
-(void)onKeyBoardWillHide:(NSNotification*)notification{//delete
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark - 取消旋转提示
-(void)onSingleTap{
    [self.progressAlert hide:YES];
    [self.maskLayerView setHidden:YES];
    self.isIndicatorCancelled = YES;
}

#pragma mark - 屏幕竖屏
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
