//
//  BindAlarmEmailController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;
@class  MBProgressHUD;
@class AlarmSettingController;
@class TableViewWithBlock;
@interface BindAlarmEmailController : UIViewController<UITextViewDelegate,UIAlertViewDelegate,UITextFieldDelegate>{
    BOOL isOpened;
}

@property (strong, nonatomic) AlarmSettingController *alarmSettingController;
@property (strong, nonatomic) Contact *contact;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (strong, nonatomic) UIView *maskLayerView;

@property (nonatomic) BOOL isUnbindEmail;//YES表示解除绑定邮箱
//YES表示取消保存或解除时的指示器，并不接收设备返回的任何数据
@property (nonatomic) BOOL isIndicatorCancelled;
//YES表示APP发送set/get命令成功，ack_receiveRemoteMessage里不用做任何处理
//防止频繁发送set/get命令
@property (nonatomic) BOOL isCommandSentOk;


@property (nonatomic, strong) UITextField *field1;


//YES表示第一次进入邮箱绑定界面时，显示的界面是defaultView
//NO表示是manualView
@property (nonatomic) BOOL isFirstInterfaceDefaultView;

@property (strong,nonatomic) NSArray *smtpServerArray;
@property (nonatomic, strong) NSString *smtpServer;
@property (strong,nonatomic) NSArray *smtpPortArray;
@property (nonatomic, strong) NSString *smtpPort;
@property (strong,nonatomic) NSArray *emailArray;

@property (nonatomic, strong) UIView *defaultView;//email新调整
@property (nonatomic, strong) UITextField *senderTextField;
@property (nonatomic, strong) UITextField *smtpTextField;
@property (nonatomic, strong) UIButton *dropDownBtn;
@property (nonatomic, strong) TableViewWithBlock *tableView;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UIView *d_manualBtnView;
@property (nonatomic, strong) UILabel *pwdPromptLabel;
@property (nonatomic, strong) UIButton *unbindButton;
@property (nonatomic, strong) UITextView *subjectTextView;
@property (nonatomic, strong) UITextView *contentTextView;


@property (nonatomic, strong) UIScrollView *manualView;//email新调整
@property (nonatomic, strong) UITextField *m_receiverTextField;
@property (nonatomic, strong) UITextField *m_senderTextField;
@property (nonatomic, strong) UITextField *m_smtpTextField;
@property (nonatomic, strong) UITextField *m_portTextField;
@property (nonatomic, strong) UIButton *m_dropDownBtn;
@property (nonatomic, strong) TableViewWithBlock *m_tableView;
@property (nonatomic, strong) UITextField *m_pwdTextField;
@property (nonatomic, strong) UITextField *m_encryptBgView;
@property (nonatomic, strong) UIView *m_encryptView;
@property (nonatomic) int m_encryptType;//加密类型  0:不加密1:SSL加密 2:TLS加密
@property (nonatomic, strong) UILabel *m_pwdPromptLabel;
@property (nonatomic, strong) UIButton *m_unbindButton;
@property (nonatomic, strong) UIView *m_manualBtnView;
@property (strong,nonatomic) NSArray *m_portArray;
@property (nonatomic) BOOL m_isHiddenEncryptView;//标记当前的显示状态
@property (nonatomic) BOOL m_isHiddenPwdPromptLabel;//标记当前的显示状态
@property (nonatomic) BOOL m_isHiddenUnbindButton;//标记当前的显示状态
@property (nonatomic, strong) NSString *m_pwdPromptLabelText;


@end
