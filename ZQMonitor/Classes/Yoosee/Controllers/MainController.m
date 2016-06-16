//
//  MainController.m
//  Yoosee
//
//  Created by guojunyi on 14-3-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "MainController.h"
#import "ContactController.h"
#import "MessageController.h"
#import "KSDWebImageRootViewController.h"
#import "MoreController.h"
#import "P2PVideoController.h"
#import "Constants.h"
#import "P2PClient.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "P2PMonitorController.h"
#import "Toast+UIView.h"
#import "P2PCallController.h"
#import "AutoNavigation.h"
#import "GlobalThread.h"
#import "AccountResult.h"
#import "NetManager.h"
#import "AppDelegate.h"
#import "LoginController.h"
#import "FListManager.h"
#import "ContactController_ap.h"
#import "Utils.h"

@interface MainController ()

@end

@implementation MainController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL result = NO;
    if ([[AppDelegate sharedDefault] dwApContactID] == 0) {
        LoginResult *loginResult = [UDManager getLoginInfo];
        result = [[P2PClient sharedClient] p2pConnectWithId:loginResult.contactId codeStr1:loginResult.rCode1 codeStr2:loginResult.rCode2];
    }
    else
    {
        //ap模式匿名登陆
        result = [[P2PClient sharedClient] p2pConnectWithId:@"0517400" codeStr1:@"0" codeStr2:@"0"];
    }
    if(result){
        DLog(@"p2pConnect success.");
    }else{//new added
        [UDManager setIsLogin:NO];
        
        //[[GlobalThread sharedThread:NO] kill];//在contactController里创建
        [[FListManager sharedFList] setIsReloadData:YES];
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        LoginController *loginController = [[LoginController alloc] init];
        loginController.isP2PVerifyCodeError = YES;
        AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
        
        [AppDelegate sharedDefault].window.rootViewController = mainController;
        [loginController release];
        [mainController release];
        DLog(@"p2pConnect failure.");
        return;
    }
    
    
    [[P2PClient sharedClient] setDelegate:self];
    [self initComponent];
    
	// Do any additional setup after loading the view.
   
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //只有从监控界面退出（dismiss）时，才进入viewDidAppear
    self.isShowingMonitorController = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initComponent{
    
    //contact
    AutoNavigation *controller1 = nil;
    if ([[AppDelegate sharedDefault] dwApContactID] == 0)
    {
        ContactController *contactController = [[ContactController alloc] init];
        contactController.isFromLoginVC = YES;
        controller1 = [[AutoNavigation alloc] initWithRootViewController:contactController];
        [contactController release];
    }
    else
    {
        ContactController_ap *contactController_ap = [[ContactController_ap alloc] init];
        controller1 = [[AutoNavigation alloc] initWithRootViewController:contactController_ap];
        [contactController_ap release];
    }
    
    //message
    AutoNavigation *controller2 = nil;
    if ([[AppDelegate sharedDefault] dwApContactID] == 0) {
        MessageController *messageController = [[MessageController alloc] init];
        controller2 = [[AutoNavigation alloc] initWithRootViewController:messageController];
        [messageController release];
    }
    
    //Screenshot
    KSDWebImageRootViewController *screenshotController = [[KSDWebImageRootViewController alloc] init];
    
    UINavigationController *controller3 = [[UINavigationController alloc] initWithRootViewController:screenshotController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [controller3.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:XHeadBarTextColor,UITextAttributeTextColor,[UIFont boldSystemFontOfSize:XHeadBarTextSize],UITextAttributeFont,nil]];
        [controller3.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_navigation_bar.png"] forBarMetrics:UIBarMetricsDefault];
        if([UIDevice currentDevice].systemVersion.floatValue < 7.0){
            controller3.navigationBar.clipsToBounds = YES;//iPod
        }
        
    }else{
        [[controller3 navigationBar] setBarStyle:UIBarStyleBlack];
    }
    
    [screenshotController release];
    
    //more
    AutoNavigation *controller5 = nil;
    if ([[AppDelegate sharedDefault] dwApContactID] == 0){
        MoreController *moreController = [[MoreController alloc] init];
        controller5 = [[AutoNavigation alloc] initWithRootViewController:moreController];
        [moreController release];
    }
    
    if ([[AppDelegate sharedDefault] dwApContactID] == 0) {
        [self setViewControllers:@[controller1,controller2,controller3,controller5]];
        [controller1 release];
        [controller2 release];
        [controller3 release];
        [controller5 release];
    }
    else
    {
        [self setViewControllers:@[controller1,controller3]];
        [controller1 release];
        [controller3 release];
    }
    
    [self setSelectedIndex:0];
}

#pragma mark - 进入呼叫设备界面1
-(void)setUpCallWithId:(NSString *)contactId password:(NSString *)password callType:(P2PCallType)type{
    [[P2PClient sharedClient] setIsBCalled:NO];
    [[P2PClient sharedClient] setCallId:contactId];
    [[P2PClient sharedClient] setP2pCallType:type];
    [[P2PClient sharedClient] setCallPassword:password];

    //rtsp监控界面弹出修改
    if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_VIDEO){
        if(!self.presentedViewController){
            
            P2PCallController *p2pCallController = [[P2PCallController alloc] init];
            p2pCallController.contactName = self.contactName;
            
            AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
            [self presentViewController:controller animated:YES completion:^{
                
            }];
            [p2pCallController release];
            [controller release];
        }
        
    }else{
        /*
         *1. 用线程延时100毫秒来呈现监控界面
         *2. 目的是，等待上个动画结束了，再模态监控界面
         *3. 效果是，就不会出现APP接收到门铃推送，进入监控且返回时，设备列表cell的不正常显示(9.1)
         */
        [NSThread detachNewThreadSelector:@selector(presentMonitorInterface) toTarget:self withObject:nil];
    }
}

-(void)presentMonitorInterface{
    usleep(100000);
    dispatch_async(dispatch_get_main_queue(), ^{
        /*
         * 1. 点击监控，直接进入监控界面
         * 2. 在监控界面上，调用接口，向设备端发送监控连接
         * 3. 发送监控连接的同时，界面提示正在连接
         */
        if (!self.isShowingMonitorController) {
            self.isShowingMonitorController = YES;
            P2PMonitorController *monitorController = [[P2PMonitorController alloc] init];
            [self presentViewController:monitorController animated:YES completion:nil];
            [monitorController release];
        }
    });
}

-(void)P2PClientCalling:(NSDictionary*)info{
    DLog(@"P2PClientCalling");
    BOOL isBCalled = [[P2PClient sharedClient] isBCalled];
    NSString *callId = [[P2PClient sharedClient] callId];
    if(isBCalled){
        if([[AppDelegate sharedDefault] isGoBack]){
            UILocalNotification *alarmNotify = [[[UILocalNotification alloc] init] autorelease];
            alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
            alarmNotify.soundName = @"default";
            alarmNotify.alertBody = [NSString stringWithFormat:@"%@:Calling!",callId];
            alarmNotify.applicationIconBadgeNumber = 1;
            alarmNotify.alertAction = NSLocalizedString(@"open", nil);
            [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
            return;
        }
        
        if(!self.isShowP2PView){
            self.isShowP2PView = YES;
            UIViewController *presentView1 = self.presentedViewController;
            UIViewController *presentView2 = self.presentedViewController.presentedViewController;
            if(presentView2){
                [self dismissViewControllerAnimated:YES completion:^{
                    P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                    AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                    
                    [self presentViewController:controller animated:YES completion:^{
                        
                    }];
                    
                    [p2pCallController release];
                    [controller release];
                }];
            }else if(presentView1){
                [presentView1 dismissViewControllerAnimated:YES completion:^{
                    P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                    AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                    
                    [self presentViewController:controller animated:YES completion:^{
                        
                    }];
                    
                    [p2pCallController release];
                    [controller release];
                }];
            }else{
                P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                
                [self presentViewController:controller animated:YES completion:^{
                    
                }];
                
                [p2pCallController release];
                [controller release];
            }
            
            
        }
        
    }
}

-(void)dismissP2PView{
    UIViewController *presentView1 = self.presentedViewController;
    UIViewController *presentView2 = self.presentedViewController.presentedViewController;
    if(presentView2){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [presentView1 dismissViewControllerAnimated:YES completion:nil];
    }
    self.isShowP2PView = NO;
}

-(void)dismissP2PView:(void (^)())callBack{
    UIViewController *presentView1 = self.presentedViewController;
    UIViewController *presentView2 = self.presentedViewController.presentedViewController;
    if(presentView2){
        [self dismissViewControllerAnimated:NO completion:^{
            callBack();
        }];
    }else if(presentView1){
        [presentView1 dismissViewControllerAnimated:NO completion:^{
            callBack();
        }];
    }else{
        callBack();
    }
    self.isShowP2PView = NO;
}

#pragma mark - 挂断监控设备回调
-(void)P2PClientReject:(NSDictionary*)info{
    DLog("P2PClientReject");
    

    
    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_NONE];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        usleep(500000);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            int errorFlag = [[info objectForKey:@"errorFlag"] intValue];
            if ([AppDelegate sharedDefault].isMonitoring) {
                [AppDelegate sharedDefault].isMonitoring = NO;//挂断，不处于监控状态
            }
            //监控、视频通话或呼叫状态下
            //不是从监控中再进入监控的方式时，则在此处调用dismiss
            //若是从监控中再进入监控的方式时，则不必调用dismiss，因为已经主动调用dismiss了
            if(![AppDelegate sharedDefault].isIntoMonitorFromMonitor){
                [self dismissP2PView];
            }else{
                [AppDelegate sharedDefault].isIntoMonitorFromMonitor = NO;
            }
            
            switch(errorFlag)
            {
                case CALL_ERROR_NONE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_unknown_error", nil)];
                    break;
                }
                case CALL_ERROR_DESID_NOT_ENABLE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_disabled", nil)];
                    break;
                }
                case CALL_ERROR_DESID_OVERDATE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_overdate", nil)];
                    break;
                }
                case CALL_ERROR_DESID_NOT_ACTIVE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_inactived", nil)];

                    break;
                }
                case CALL_ERROR_DESID_OFFLINE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_offline", nil)];

                    break;
                }
                case CALL_ERROR_DESID_BUSY:
                {
                    [self.view makeToast:NSLocalizedString(@"id_busy", nil)];

                    break;
                }
                case CALL_ERROR_DESID_POWERDOWN:
                {
                    [self.view makeToast:NSLocalizedString(@"id_powerdown", nil)];

                    break;
                }
                case CALL_ERROR_NO_HELPER:
                {
                    [self.view makeToast:NSLocalizedString(@"id_connect_failed", nil)];

                    break;
                }
                case CALL_ERROR_HANGUP:
                {
                    [self.view makeToast:NSLocalizedString(@"id_hangup", nil)];

                    break;
                }
                case CALL_ERROR_TIMEOUT:
                {
                    [self.view makeToast:NSLocalizedString(@"id_timeout", nil)];

                    break;
                }
                case CALL_ERROR_INTER_ERROR:
                {
                    [self.view makeToast:NSLocalizedString(@"id_internal_error", nil)];

                    break;
                }
                case CALL_ERROR_RING_TIMEOUT:
                {
                    [self.view makeToast:NSLocalizedString(@"id_no_accept", nil)];

                    break;
                }
                case CALL_ERROR_PW_WRONG:
                {
                    [self.view makeToast:NSLocalizedString(@"id_password_error", nil)];

                    break;
                }
                case CALL_ERROR_CONN_FAIL:
                {
                    [self.view makeToast:NSLocalizedString(@"id_connect_failed", nil)];
                    break;
                }
                case CALL_ERROR_NOT_SUPPORT:
                {
                    [self.view makeToast:NSLocalizedString(@"id_not_support", nil)];
                    break;
                }
                default:
                    [self.view makeToast:NSLocalizedString(@"id_unknown_error", nil)];

                    break;
            }
        });
    });
    
    
    
    
}


-(void)P2PClientAccept:(NSDictionary*)info{
    DLog(@"P2PClientAccept");
}

#pragma mark - 连接设备就绪
-(void)P2PClientReady:(NSDictionary*)info{
    DLog(@"P2PClientReady");
    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_READY_P2P];
    
    if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_MONITOR){
        //rtsp监控界面弹出修改
        /*
         * 监控连接已经准备就绪，发送监控开始渲染通知
         * 在监控界面上，接收通知，并开始渲染监控画面
         */
        [[NSNotificationCenter defaultCenter] postNotificationName:MONITOR_START_RENDER_MESSAGE
                                                            object:self
                                                          userInfo:NULL];
    }else if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_VIDEO){
        P2PVideoController *videoController = [[P2PVideoController alloc] init];
        if (self.presentedViewController) {
            [self.presentedViewController presentViewController:videoController animated:YES completion:nil];
        }else{
            [self presentViewController:videoController animated:YES completion:nil];
        }
        
        [videoController release];
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
