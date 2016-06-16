//
//  ZQAppDelegate.m
//  ZQMonitor
//
//  Created by ZQ on 06/16/2016.
//  Copyright (c) 2016 ZQ. All rights reserved.
//
//#import "MainController.h"
//#import "UDManager.h"
//#import "LoginController.h"
//#import "Constants.h"
//#import "AutoNavigation.h"
//#import "LoginResult.h"
//#import "UDManager.h"
//#import "NetManager.h"
//#import "AccountResult.h"
//#import "Reachability.h"
//#import "P2PMessage.h"
//#import "Utils.h"
//#import "MessageDAO.h"
//#import "FListManager.h"
//#import "CheckNewMessageResult.h"
//#import "GetContactMessageResult.h"
//#import "CheckAlarmMessageResult.h"
//#import "ContactDAO.h"
//#import "GlobalThread.h"
//#import "Contact.h"
//#import "Toast+UIView.h"
//#import "UncaughtExceptionHandler.h"
//#import "Alarm.h"
//#import "AlarmDAO.h"
//#import "MPNotificationView.h"
//#import "LaunchImageTransition.h"
//#import "AlarmPushController.h"//door ring push
//#import "UDPManager.h"
//#import "PAIOUnit.h"//rtsp监控界面弹出修改
//#import "MD5Manager.h"
#import "ZQAppDelegate.h"

@implementation ZQAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{//P2P
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(tapReceivedNotificationHandler:)
//                                                 name:kMPNotificationViewTapReceivedNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSessionIdError:) name:NOTIFICATION_ON_SESSION_ERROR object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveAlarmMessage:) name:RECEIVE_ALARM_MESSAGE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveDoorbellAlarmMessage:) name:RECEIVE_DOORBELL_ALARM_MESSAGE object:nil];
//    [[UDPManager sharedDefault] ScanLanDevice];

    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
//    if (self.isMonitoring) {
//    if ([[P2PClient sharedClient] p2pCallState] == P2PCALL_STATUS_READY_P2P) {
//        [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_NONE];
//        [[PAIOUnit sharedUnit] stopAudio];
//    }
//    [[P2PClient sharedClient] p2pHungUp];
//    [[P2PClient sharedClient] rtspHungUp];
//    if ([[AppDelegate sharedDefault] dwApContactID] == 0)
//    {
//        /*
//         *1. 为什么会在这里调用dismiss呢？
//         *2. 因为RTSP监控直接退出后台时，不会有挂断回调，所以需要在这里执行dismiss
//         *3. 而P2P监控，则不用在此dismiss
//         *4. 现在已经将RTSP监控关闭，不需要dismiss;但是以后打开RTSP功能时，则要dismiss
//         */
//        //[self.mainController dismissP2PView];
//    }
//    else
//    {
//        [self.mainController_ap dismissP2PView];
//    }
}

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    self.isForeground = NO;
//    [self hungUpRemoteCall];
//    UIApplication *app = [UIApplication sharedApplication];
//    UIBackgroundTaskIdentifier taskID;
//    taskID = [app beginBackgroundTaskWithExpirationHandler:^{
//        [[P2PClient sharedClient] p2pDisconnect];
//        [app endBackgroundTask:taskID];
//    }];
//    
//    if (taskID == UIBackgroundTaskInvalid) {
//        [[P2PClient sharedClient] p2pDisconnect];
//        NSLog(@"Failed to start background task!");
        return;
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
////YOOSEE
//#pragma mark - 返回三种类型的rect，分别是水平、7.0和其他情况
//+(CGRect)getScreenSize:(BOOL)isNavigation isHorizontal:(BOOL)isHorizontal{
//    CGRect rect = [UIScreen mainScreen].bounds;
//    
//    if(isHorizontal){
//        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
//    }
//    
//    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0){
//        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-20);
//    }
//    return rect;
//}
//+ (AppDelegate*)sharedDefault
//{
//    
//    return [UIApplication sharedApplication].delegate;
//}
//+(NSString*)getAppVersion{
//    return [NSString stringWithFormat:APP_VERSION];
//}
//-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
//    return UIInterfaceOrientationMaskAll;
//}
//- (void)tapReceivedNotificationHandler:(NSNotification *)notice
//{
//    MPNotificationView *notificationView = (MPNotificationView *)notice.object;
//    if ([notificationView isKindOfClass:[MPNotificationView class]])
//    {
//        //NSLog( @"Received touch for notification with text: %@", ((MPNotificationView *)notice.object).textLabel.text );
//        [self.mainController setSelectedIndex:1];
//        [self.mainController setBottomBarHidden:NO];
//        self.isNotificationBeClicked = YES;
//        self.window.rootViewController = self.mainController;
//    }
//}
//-(void)onSessionIdError:(id)sender{
//    [[P2PClient sharedClient] p2pHungUp];
//    [[P2PClient sharedClient] rtspHungUp];
//    
//    [self.mainController dismissP2PView];
//    [UDManager setIsLogin:NO];
//    
//    [[GlobalThread sharedThread:NO] kill];
//    [[FListManager sharedFList] setIsReloadData:YES];
//    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
//    LoginController *loginController = [[LoginController alloc] init];
//    loginController.isSessionIdError = YES;
//    AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
//    
//    [AppDelegate sharedDefault].window.rootViewController = mainController;
//    
//    
//    dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
//    dispatch_async(queue, ^{
//        [[P2PClient sharedClient] p2pDisconnect];
//        DLog(@"p2pDisconnect.");
//    });
//}
//
//-(NSString *)groupName:(int)group{//addgroupItem
//    NSString *groupName = @"";
//    switch(group){
//        case 1:
//        {
//            groupName = NSLocalizedString(@"hall", nil);
//        }
//            break;
//        case 2:
//        {
//            groupName = NSLocalizedString(@"window", nil);
//        }
//            break;
//        case 3:
//        {
//            groupName = NSLocalizedString(@"balcony", nil);
//        }
//            break;
//        case 4:
//        {
//            groupName = NSLocalizedString(@"bedroom", nil);
//        }
//            break;
//        case 5:
//        {
//            groupName = NSLocalizedString(@"kitchen", nil);
//        }
//            break;
//        case 6:
//        {
//            groupName = NSLocalizedString(@"courtyard", nil);
//        }
//            break;
//        case 7:
//        {
//            groupName = NSLocalizedString(@"door_lock", nil);
//        }
//            break;
//        case 8:
//        {
//            groupName = NSLocalizedString(@"other", nil);
//        }
//            break;
//    }
//    return groupName;
//}
//
//- (void)onReceiveAlarmMessage:(NSNotification *)notification{
//    NSDictionary *parameter = [notification userInfo];
//    
//    //contact name
//    NSString *contactId   = [parameter valueForKey:@"contactId"];
//    ContactDAO *contactDAO = [[ContactDAO alloc] init];
//    Contact *contact = [contactDAO isContact:contactId];
//    NSString *contactName = contact.contactName;
//    
//    //YES 表示删除绑定的报警推送ID,显示“解绑”按钮
//    BOOL isSupportDelAlarmPushId = [[parameter valueForKey:@"isSupportDelAlarmPushId"] boolValue];
//    
//    //contact type
//    int type   = [[parameter valueForKey:@"type"] intValue];
//    
//    //防区、通道
//    int group   = [[parameter valueForKey:@"group"] intValue];
//    int item   = [[parameter valueForKey:@"item"] intValue];
//    
//    //推送提示消息
//    NSString *message2 = @"";//addgroupItem
//    NSString *leftSpace = @"";
//    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0 && [UIDevice currentDevice].systemVersion.floatValue >= 7.0){
//        leftSpace = @"";//
//    }else{
//        leftSpace = @"                ";//16
//    }
//    
//    
//    //根据报警类型显示文字
//    NSString *typeStr = @"";
//    BOOL isUnknownType = NO;
//    switch(type){
//        case 1:
//        {
//            typeStr = NSLocalizedString(@"extern_alarm", nil);
//            if (group>=1 && group<=8) {//addgroupItem
//                message2 = [NSString stringWithFormat:@"%@%@ :%@\n%@%@ :%d",leftSpace,NSLocalizedString(@"defence_group", nil),[self groupName:group],leftSpace,NSLocalizedString(@"defence_item", nil),item+1];
//            }
//        }
//            break;
//        case 2:
//        {
//            typeStr = NSLocalizedString(@"motion_dect_alarm", nil);
//        }
//            break;
//        case 3:
//        {
//            typeStr = NSLocalizedString(@"emergency_alarm", nil);
//        }
//            break;
//        case 4:
//        {
//            typeStr = NSLocalizedString(@"debug_alarm", nil);
//        }
//            break;
//        case 5:
//        {
//            typeStr = NSLocalizedString(@"ext_line_alarm", nil);
//        }
//            break;
//        case 6:
//        {
//            typeStr = NSLocalizedString(@"low_vol_alarm", nil);
//        }
//            break;
//        case 7:
//        {
//            typeStr = NSLocalizedString(@"pir_alarm", nil);
//        }
//            break;
//        case 8:
//        {
//            typeStr = NSLocalizedString(@"defence_alarm", nil);
//        }
//            break;
//        case 9:
//        {
//            typeStr = NSLocalizedString(@"defence_disable_alarm", nil);
//        }
//            break;
//        case 10:
//        {
//            typeStr = NSLocalizedString(@"battery_low_vol", nil);
//        }
//            break;
//        case 11:
//        {
//            typeStr = NSLocalizedString(@"update_to_ser", nil);
//        }
//            break;
//        case 13://门铃报警类型
//        {
//            typeStr = NSLocalizedString(@"somebody_visit", nil);
//        }
//            break;
//        default:
//        {
//            //未知类型
//            typeStr = [NSString stringWithFormat:@"%d",type];
//            isUnknownType = YES;
//        }
//            break;
//    }
//    
//    
//    //APP在后台
//    if(self.isGoBack){
//        UILocalNotification *alarmNotify = [[UILocalNotification alloc] init];
//        alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
//        alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
//        alarmNotify.soundName = [self playAlarmMessageRingWithAlarmType:type isBeBackground:YES];
//        if ([contactId isEqualToString:contactName] || contactName == nil) {
//            alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactId,typeStr];
//        }else{
//            alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactName,typeStr];
//        }
//        alarmNotify.applicationIconBadgeNumber = 1;
//        alarmNotify.alertAction = NSLocalizedString(@"open", nil);
//        [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
//    }
//    
//    
//    //alarmContactId正处于被监控状态,不作推送
//    if ([self.monitoredContactId isEqualToString:contactId]) {
//        return;
//    }
//    
//    
//    //alarmContactId正处于弹出状态,不作推送
//    if ([self.currentPushedContactId isEqualToString:contactId]) {
//        return;
//    }
//    
//    
//    //YES表示接收到推送，正在输入密码准备进行监控，此时不弹出任何推送
//    if (self.isInputtingPwdToMonitor) {
//        return;
//    }
//    
//    
//    //YES表示正显示门铃推送界面，不弹出任何推送
//    if (self.isShowingDoorBellAlarm) {
//        return;
//    }
//    
//    
//    //isCanShow = NO表示监控中
//    P2PCallState p2pCallState = [[P2PClient sharedClient] p2pCallState];
//    BOOL isCanShow = NO;
//    if(p2pCallState==P2PCALL_STATUS_NONE){
//        isCanShow = YES;
//    }else{
//        isCanShow = NO;
//    }
//    
//    //上一次与当前推送的时间间隔,超过10秒，则弹出推送框
//    BOOL isTimeAfter = NO;
//    if(([Utils getCurrentTimeInterval]-self.lastShowAlarmTimeInterval)>10){
//        isTimeAfter = YES;
//        
//    }else{
//        isTimeAfter = NO;
//    }
//    
//    
//    
//    //弹出推送提示框，一是门铃推送，二是其他
//    if(isTimeAfter&&!self.isGoBack){//alarmAlertview   isCanShow&&
//        [self playAlarmMessageRingWithAlarmType:type isBeBackground:NO];//播放推送铃声
//        
//        self.alarmContactId = contactId;
//        self.currentPushedContactId = contactId;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (type == 13 && isCanShow) {//为门铃推送,isCanShow为YES表示不在监控中...
//                self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
//                self.isShowingDoorBellAlarm = YES;//表示正显示门铃推送界面
//                
//                //_alarmAlertView存在时，在弹出门铃推送界面前，先收起当前的提示
//                if (_alarmAlertView) {
//                    [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
//                    _alarmAlertView = nil;//alarmAlertview
//                }
//                
//                //显示门铃推送界面
//                [self.mainController dismissP2PView];//在"报警设置"进入AlarmPushController前执行,若不执行，则会导致从AlarmPushController返回时，无法再进入"报警设置"
//                AlarmPushController * alarmpushcontroller = [[AlarmPushController alloc] init];//door ring push
//                alarmpushcontroller.contactId = contactId;
//                alarmpushcontroller.contactName = contactName;
//                self.window.rootViewController = alarmpushcontroller;
//                
//            }else{//为其他推送
//                if (type == 13 && !isCanShow) {//为门铃推送,isCanShow为NO表示在监控中...
//                    self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
//                }else{
//                    self.isDoorBellAlarm = NO;//在监控界面使用,区分门铃推送，其他推送
//                }
//                
//                
//                //_alarmAlertView存在时，在弹出下一个提示前，先收起当前的提示
//                if (_alarmAlertView) {
//                    [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
//                }
//                //显示其他推送提示
//                NSString* title = @"";
//                NSString *message = @"";
//                if (isUnknownType) {
//                    message = [NSString stringWithFormat:@"%@%@%@\n%@\n",leftSpace,NSLocalizedString(@"unknown_type", nil),typeStr,message2];
//                }else{
//                    message = [NSString stringWithFormat:@"%@%@%@\n%@\n",leftSpace,NSLocalizedString(@"alarm_type", nil),typeStr,message2];
//                }
//                
//                if ([contactId isEqualToString:contactName] || contactName == nil) {
//                    
//                    title = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"device", nil),contactId] ;
//                    
//                }else {
//                    
//                    title = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"device", nil),contactName];
//                    
//                }
//                
//                _alarmAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"view", nil) otherButtonTitles:NSLocalizedString(@"cancel", nil),nil] ;
//                if (isSupportDelAlarmPushId) {//删除绑定的报警推送ID
//                    [_alarmAlertView addButtonWithTitle:NSLocalizedString(@"delete_alarm_push_id", nil)];
//                }
//                _alarmAlertView.tag = ALERT_TAG_ALARMING;
//                
//                //UIAlertView 左对齐 iOS7及iOS6不同处理
//                if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0){
//                    CGSize size = [_alarmAlertView.message sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(240,400) lineBreakMode:NSLineBreakByTruncatingTail];
//                    
//                    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, -120,size.width, size.height)];
//                    textLabel.font = [UIFont systemFontOfSize:15];
//                    textLabel.textColor = [UIColor blackColor];
//                    textLabel.backgroundColor = [UIColor clearColor];
//                    textLabel.lineBreakMode =NSLineBreakByWordWrapping;
//                    textLabel.numberOfLines =0;
//                    textLabel.textAlignment =NSTextAlignmentLeft;
//                    textLabel.text = _alarmAlertView.message;
//                    [_alarmAlertView setValue:textLabel forKey:@"accessoryView"];
//                    
//                    _alarmAlertView.message =@"";
//                }
//                [_alarmAlertView show];
//            }
//        });//alarmAlertview
//    }
//}
//
//- (void)willPresentAlertView:(UIAlertView *)alertView{
//    //UIAlertView 左对齐 iOS7及iOS6不同处理
//    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) {
//        NSInteger count = 0;
//        for( UIView * view in _alarmAlertView.subviews )
//        {
//            if( [view isKindOfClass:[UILabel class]] )
//            {
//                count ++;
//                if ( count == 2 ) { //仅对message左对齐
//                    UILabel* label = (UILabel*) view;
//                    label.textAlignment =NSTextAlignmentLeft;
//                }
//            }
//        }
//    }
//}
//
//#pragma mark - 透传门铃（安尔发...）
//-(void)onReceiveDoorbellAlarmMessage:(NSNotification *)notification{
//    NSDictionary *parameter = [notification userInfo];
//    
//    NSString *cmd = [parameter valueForKey:@"cmd"];
//    
//    if ([cmd isEqualToString:@"anerfa:disconnect"]) {
//        NSString *contactId = [parameter valueForKey:@"contactId"];
//        ContactDAO *contactDAO = [[ContactDAO alloc] init];
//        Contact *contact = [contactDAO isContact:contactId];
//        [[P2PClient sharedClient] sendCustomCmdWithId:contactId password:contact.contactPassword cmd:@"IPC1anerfa:disconnect"];
//        
//    }else if ([[cmd substringToIndex:11] isEqualToString:@"anerfa:call"]) {
//        NSString *contactId = [parameter valueForKey:@"contactId"];
//        ContactDAO *contactDAO = [[ContactDAO alloc] init];
//        Contact *contact = [contactDAO isContact:contactId];
//        NSString *contactName = contact.contactName;
//        
//        NSString *typeStr = NSLocalizedString(@"somebody_visit", nil);
//        
//        //后台推送
//        if(self.isGoBack){
//            UILocalNotification *alarmNotify = [[UILocalNotification alloc] init];
//            alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
//            alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
//            alarmNotify.soundName = [self playAlarmMessageRingWithAlarmType:13 isBeBackground:YES];
//            if ([contactId isEqualToString:contactName] || contactName == nil) {
//                alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactId,typeStr];
//            }else{
//                alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactName,typeStr];
//            }
//            alarmNotify.applicationIconBadgeNumber = 1;
//            alarmNotify.alertAction = NSLocalizedString(@"open", nil);
//            [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
//        }
//        
//        
//        //alarmContactId正处于被监控状态,不作推送
//        if ([self.monitoredContactId isEqualToString:contactId]) {
//            return;
//        }
//        
//        
//        //alarmContactId正处于弹出状态,不作推送
//        if ([self.currentPushedContactId isEqualToString:contactId]) {
//            return;
//        }
//        
//        
//        //YES表示接收到推送，正在输入密码准备进行监控，此时不弹出任何推送
//        if (self.isInputtingPwdToMonitor) {
//            return;
//        }
//        
//        
//        //YES表示正显示门铃推送界面，不弹出任何推送
//        if (self.isShowingDoorBellAlarm) {
//            return;
//        }
//        
//        
//        //isCanShow = NO表示监控中
//        P2PCallState p2pCallState = [[P2PClient sharedClient] p2pCallState];
//        BOOL isCanShow = NO;
//        if(p2pCallState==P2PCALL_STATUS_NONE){
//            isCanShow = YES;
//        }else{
//            isCanShow = NO;
//        }
//        
//        
//        //上一次与当前推送的时间间隔,超过10秒，则弹出推送框
//        BOOL isTimeAfter = NO;
//        if(([Utils getCurrentTimeInterval]-self.lastShowAlarmTimeInterval)>10){
//            isTimeAfter = YES;
//            
//        }else{
//            isTimeAfter = NO;
//        }
//        
//        
//        
//        if(isTimeAfter&&!self.isGoBack){//alarmAlertview
//            [self playAlarmMessageRingWithAlarmType:13 isBeBackground:NO];//播放推送铃声
//            
//            self.alarmContactId = contactId;
//            self.currentPushedContactId = contactId;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (isCanShow) {//为门铃推送,isCanShow为YES表示不在监控中...
//                    self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
//                    self.isShowingDoorBellAlarm = YES;//表示正显示门铃推送界面
//                    
//                    //_alarmAlertView存在时，在弹出门铃推送界面前，先收起当前的提示
//                    if (_alarmAlertView) {
//                        [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
//                        _alarmAlertView = nil;//alarmAlertview
//                    }
//                    
//                    //显示门铃推送界面
//                    [self.mainController dismissP2PView];//在"报警设置"进入AlarmPushController前执行,若不执行，则会导致从AlarmPushController返回时，无法再进入"报警设置"
//                    AlarmPushController * alarmpushcontroller = [[AlarmPushController alloc] init];//door ring push
//                    alarmpushcontroller.contactId = contactId;
//                    alarmpushcontroller.contactName = contactName;
//                    self.window.rootViewController = alarmpushcontroller;
//                    
//                }else{//为门铃推送,isCanShow为NO表示在监控中...
//                    self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
//                    
//                    //_alarmAlertView存在时，在弹出下一个提示前，先收起当前的提示
//                    if (_alarmAlertView) {
//                        [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
//                    }
//                    //显示其他推送提示
//                    if ([contactId isEqualToString:contactName] || contactName == nil) {
//                        NSString* title = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"device", nil),contactId] ;
//                        NSString *message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"alarm_type", nil),typeStr];
//                        _alarmAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"view", nil) otherButtonTitles:NSLocalizedString(@"cancel", nil),nil] ;
//                        _alarmAlertView.tag = ALERT_TAG_ALARMING;
//                        [_alarmAlertView show];
//                    }else {
//                        NSString* title = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"device", nil),contactName] ;
//                        NSString *message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"alarm_type", nil),typeStr];
//                        _alarmAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"view", nil) otherButtonTitles:NSLocalizedString(@"cancel", nil),nil];
//                        _alarmAlertView.tag = ALERT_TAG_ALARMING;
//                        [_alarmAlertView show];
//                    }
//                }
//                
//            });
//        }//alarmAlertview
//    }else{
//        //unknown error
//    }
//}
//
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    [self stopToPlayAlarmRing];
//    
//    switch(alertView.tag){
//        case ALERT_TAG_ALARMING:
//        {
//            _alarmAlertView = nil;//alarmAlertview
//            if(buttonIndex==0){
//                ContactDAO *contactDAO = [[ContactDAO alloc] init];
//                Contact *contact = [contactDAO isContact:self.alarmContactId];
//                
//                if(nil!=contact){
//                    self.currentPushedContactId = nil;
//                    
//                    if ([[P2PClient sharedClient] p2pCallState] == P2PCALL_STATUS_READY_P2P) {
//                        [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_NONE];
//                        [[PAIOUnit sharedUnit] stopAudio];
//                    }//rtsp监控界面弹出修改
//                    if (self.isMonitoring) {
//                        self.isIntoMonitorFromMonitor = YES;//YES表示APP端从监控中再进入监控的方式
//                    }
//                    if ([[P2PClient sharedClient] p2pCallState] == P2PCALL_STATUS_READY_RTSP) {
//                        //p2p连接时，会有reject回调把isIntoMonitorFromMonitor设置为NO,但是rtsp连接没有
//                        self.isIntoMonitorFromMonitor = NO;
//                    }
//                    
//                    [[P2PClient sharedClient] p2pHungUp];
//                    
//                    self.mainController.contactName = contact.contactName;//昵称显示不对
//                    [AppDelegate sharedDefault].contact = nil;
//                    [self.mainController dismissP2PView:^{
//                        [self.mainController setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
//                        self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
//                    }];
//                    
//                }else{
//                    self.isInputtingPwdToMonitor = YES;
//                    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
//                    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
//                    UITextField *passwordField = [inputAlert textFieldAtIndex:0];
//                    passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
//                    inputAlert.tag = ALERT_TAG_MONITOR;
//                    [inputAlert show];
//                }
//            }else if(buttonIndex==2){//删除绑定的报警推送ID
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"confirm_unbind", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
//                alertView.tag = 1000;
//                [alertView show];
//            }else{//取消
//                self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
//                self.currentPushedContactId = nil;
//            }
//        }
//            break;
//        case 1000://删除绑定的报警推送ID
//        {
//            self.currentPushedContactId = nil;
//            if (buttonIndex==1) {
//                [[P2PClient sharedClient] deleteAlarmPushIDWithId:self.alarmContactId];
//            }
//        }
//            break;
//        case ALERT_TAG_MONITOR:
//        {
//            _alarmAlertView = nil;//alarmAlertview
//            self.currentPushedContactId = nil;
//            self.isInputtingPwdToMonitor = NO;
//            if(buttonIndex==1){
//                UITextField *passwordField = [alertView textFieldAtIndex:0];
//                
//                NSString *inputPwd = passwordField.text;
//                if(!inputPwd||inputPwd.length==0){
//                    [self.mainController.view makeToast:NSLocalizedString(@"input_device_password", nil)];
//                    self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
//                    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
//                    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
//                    UITextField *passwordField = [inputAlert textFieldAtIndex:0];
//                    passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
//                    inputAlert.tag = ALERT_TAG_MONITOR;
//                    [inputAlert show];
//                    return;
//                }
//                if ([[P2PClient sharedClient] p2pCallState] == P2PCALL_STATUS_READY_P2P) {
//                    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_NONE];
//                    [[PAIOUnit sharedUnit] stopAudio];
//                }//rtsp监控界面弹出修改
//                if (self.isMonitoring) {
//                    self.isIntoMonitorFromMonitor = YES;//YES表示APP端从监控中再进入监控的方式
//                }
//                if ([[P2PClient sharedClient] p2pCallState] == P2PCALL_STATUS_READY_RTSP) {
//                    //p2p连接时，会有reject回调把isIntoMonitorFromMonitor设置为NO,但是rtsp连接没有
//                    self.isIntoMonitorFromMonitor = NO;
//                }
//                [[P2PClient sharedClient] p2pHungUp];
//                
//                MainController *mainController = [AppDelegate sharedDefault].mainController;
//                mainController.contactName = self.alarmContactId;
//                
//                Contact *contact = [[Contact alloc] init];//重新调整监控画面
//                contact.contactId = self.alarmContactId;
//                contact.contactName = self.alarmContactId;
//                contact.contactPassword = [Utils GetTreatedPassword:inputPwd];
//                [AppDelegate sharedDefault].contact = contact;
//                [AppDelegate sharedDefault].mainController.contact = nil;
//                [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
//                [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];//在这为了获取设备类型,在监控界面区分门铃设备与其他设备
//                
//                [self.mainController dismissP2PView:^{
//                    [self.mainController setUpCallWithId:self.alarmContactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
//                    self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
//                }];
//                
//                
//            }else{
//                self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
//            }
//            
//        }
//            break;
//        case ALERT_TAG_APP_UPDATE://app检查更新
//        {
//            if(buttonIndex == 1){
//                //app的数字ID
//                NSString * plist = [[NSBundle mainBundle] pathForResource:@"Common-Configuration" ofType:@"plist"];
//                NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
//                NSString *appleID = dic[@"AppleID"];
//                
//                //已经上架的APP的URL
//                NSString *trackViewUrl = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", appleID];
//                NSURL *url= [NSURL URLWithString:trackViewUrl];
//                [[UIApplication sharedApplication] openURL:url];
//            }
//        }
//            break;
//    }
//}
//
//- (void)receiveRemoteMessage:(NSNotification *)notification{
//    NSDictionary *parameter = [notification userInfo];
//    int key   = [[parameter valueForKey:@"key"] intValue];
//    switch(key){
//        case RET_RECEIVE_MESSAGE:
//        {
//            NSString *contactId = [parameter valueForKey:@"contactId"];
//            NSString *messageStr = [parameter valueForKey:@"message"];
//            LoginResult *loginResult = [UDManager getLoginInfo];
//            MessageDAO *messageDAO = [[MessageDAO alloc] init];
//            P2PMessage *message = [[P2PMessage alloc] init];
//            
//            message.fromId = contactId;
//            message.toId = loginResult.contactId;
//            message.message = [NSString stringWithFormat:@"%@",messageStr];
//            message.state = MESSAGE_STATE_NO_READ;
//            message.time = [NSString stringWithFormat:@"%ld",[Utils getCurrentTimeInterval]];
//            message.flag = -1;
//            [messageDAO insert:message];
//            
//            int lastCount = [[FListManager sharedFList] getMessageCount:contactId];
//            [[FListManager sharedFList] setMessageCountWithId:contactId count:lastCount+1];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
//                                                                    object:self
//                                                                  userInfo:nil];
//            });
//            
//            UILocalNotification *notification = [[UILocalNotification alloc] init];
//            notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
//            notification.timeZone = [NSTimeZone defaultTimeZone];
//            notification.soundName = @"message.mp3";
//            notification.alertBody = [NSString stringWithFormat:@"%@:%@",contactId,messageStr];
//            notification.applicationIconBadgeNumber = 1;
//            notification.alertAction = NSLocalizedString(@"open", nil);
//            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//        }
//            break;
//        case RET_GET_NPCSETTINGS_REMOTE_DEFENCE:
//        {
//            NSInteger state = [[parameter valueForKey:@"state"] intValue];
//            NSString *contactId = [parameter valueForKey:@"contactId"];
//            if(state==SETTING_VALUE_REMOTE_DEFENCE_STATE_ON){
//                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_ON];
//            }else{
//                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_OFF];
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
//                                                                    object:self
//                                                                  userInfo:nil];
//            });
//            DLog(@"RET_GET_NPCSETTINGS_REMOTE_DEFENCE");
//            
//        }
//            break;
//            
//    }
//    
//}
//
//- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
//    NSDictionary *parameter = [notification userInfo];
//    int key   = [[parameter valueForKey:@"key"] intValue];
//    int result   = [[parameter valueForKey:@"result"] intValue];
//    NSString *contactId = [parameter valueForKey:@"contactId"];
//    switch(key){
//        case ACK_RET_SET_STOP_DOORBELL_PUSH:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(result==2){
//                    [[P2PClient sharedClient] stopDoorbellPushWithId:self.alarmContactId];
//                }
//            });
//        }
//            break;
//        case ACK_RET_SET_DELETE_ALARM_PUSHID:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(result==2){
//                    [[P2PClient sharedClient] deleteAlarmPushIDWithId:self.alarmContactId];
//                }
//            });
//        }
//            break;
//        case ACK_RET_SEND_MESSAGE:
//        {
//            
//            
//            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                int flag = [[parameter valueForKey:@"flag"] intValue];
//                MessageDAO *messageDAO = [[MessageDAO alloc] init];
//                if(result==0){
//                    [messageDAO updateMessageStateWithFlag:flag state:MESSAGE_STATE_NO_READ];
//                }else{
//                    [messageDAO updateMessageStateWithFlag:flag state:MESSAGE_STATE_SEND_FAILURE];
//                }
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
//                                                                        object:self
//                                                                      userInfo:nil];
//                });
//            });
//            
//            
//            DLog(@"ACK_RET_GET_DEVICE_TIME:%i",result);
//        }
//            break;
//        case ACK_RET_GET_DEFENCE_STATE:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //                NSString *contactId = @"10000";
//                if(result==1){
//                    
//                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_PWD];
//                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
//                        [self.window makeToast:NSLocalizedString(@"device_password_error", nil)];
//                    }
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
//                                                                            object:self
//                                                                          userInfo:nil];
//                    });
//                }else if(result==2){
//                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_NET];
//                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
//                        [self.window makeToast:NSLocalizedString(@"net_exception", nil)];
//                    }
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
//                                                                            object:self
//                                                                          userInfo:nil];
//                    });
//                }else if (result==4){
//                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_NO_PERMISSION];
//                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
//                        [self.window makeToast:NSLocalizedString(@"no_permission", nil)];
//                    }
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
//                                                                            object:self
//                                                                          userInfo:nil];
//                    });
//                }
//                
//                [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contactId isClick:NO];
//                
//            });
//            
//            DLog(@"ACK_RET_GET_DEFENCE_STATE:%i",result);
//        }
//            break;
//        case ACK_RET_SET_NPCSETTINGS_REMOTE_DEFENCE:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(result==1){
//                    
//                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_PWD];
//                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
//                        [self.window makeToast:NSLocalizedString(@"device_password_error", nil)];
//                    }
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
//                                                                            object:self
//                                                                          userInfo:nil];
//                    });
//                }else if(result==2){
//                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_NET];
//                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
//                        [self.window makeToast:NSLocalizedString(@"net_exception", nil)];
//                    }
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
//                                                                            object:self
//                                                                          userInfo:nil];
//                    });
//                }else if (result==4){
//                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_NO_PERMISSION];
//                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
//                        [self.window makeToast:NSLocalizedString(@"no_permission", nil)];
//                    }
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
//                                                                            object:self
//                                                                          userInfo:nil];
//                    });
//                }else{
//                    ContactDAO *contactDAO = [[ContactDAO alloc] init];
//                    Contact *contact = [contactDAO isContact:contactId];
//                    if(nil!=contact){
//                        [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
//                    }
//                    
//                }
//                
//                [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contactId isClick:NO];
//                
//            });
//            DLog(@"ACK_RET_GET_DEFENCE_STATE:%i",result);
//        }
//            break;
//            
//    }
//    
//}
//#pragma mark - 报警铃声播放
//-(NSString *)playAlarmMessageRingWithAlarmType:(int)alarmType isBeBackground:(BOOL)isBackground{
//    NSURL *ringUrl = nil;
//    //return @"default";//关闭前台铃声，恢复后台默认铃声
//    switch(alarmType){
//        case 1:
//        case 2:
//        case 3:
//        case 4:
//        case 5:
//        case 6:
//        case 7:
//        case 8:
//        case 9:
//        case 10:
//        case 11:
//        {
//            return @"default";//关闭前台铃声，恢复后台默认铃声
//            
//            if(isBackground){
//                return @"alarm_push_ring.caf";
//            }
//            
//            ringUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"alarm_push_ring" ofType:@"caf"]];
//        }
//            break;
//        case 13:
//        {
//            if(isBackground){
//                return @"door_bell_ring.caf";
//            }
//            
//            //门铃报警类型
//            ringUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"door_bell_ring" ofType:@"caf"]];
//        }
//            break;
//        default:
//        {
//            return @"default";//关闭前台铃声，恢复后台默认铃声
//            
//            if(isBackground){
//                return @"unknown_push_ring.caf";
//            }
//            
//            //未知类型
//            ringUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"unknown_push_ring" ofType:@"caf"]];
//        }
//            break;
//    }
//    
//    //为什么从监控退出后，AVAudioPlayer的声音变小了
//    //解决方法：
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//    
//    //音频播放器加载音乐
//    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:ringUrl error:nil];
//    self.alarmRingPlayer = player;
//    //准备播放
//    [self.alarmRingPlayer prepareToPlay];
//    //设置声音
//    self.alarmRingPlayer.volume = 1.0;
//    //播放次数
//    self.alarmRingPlayer.numberOfLoops = 0;
//    //开始播放
//    [self.alarmRingPlayer play];
//    
//    return nil;
//}
//
//#pragma mark - 停止播放报警铃声
//-(void)stopToPlayAlarmRing{
//    if(self.alarmRingPlayer.isPlaying){
//        [self.alarmRingPlayer stop];
//        
//        
//        P2PCallState p2pCallState = [[P2PClient sharedClient] p2pCallState];
//        if(p2pCallState!=P2PCALL_STATUS_NONE){//表示监控中
//            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//        }
//    }
//}
@end
