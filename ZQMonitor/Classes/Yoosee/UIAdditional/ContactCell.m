//
//  ContactCell.m
//  Gviews
//
//  Created by guojunyi on 14-4-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ContactCell.h"
#import "Utils.h"
#import "Constants.h"
#import "Contact.h"
#import "P2PClient.h"
#import "FListManager.h"
#import "UDPManager.h"
#import "LocalDevice.h"

#define kOperatorBtnTag_Chat 23581
#define kOperatorBtnTag_Playback 23585
#define kOperatorBtnTag_Control 23586
#define kOperatorBtnTag_Modify 23583
#define kOperatorBtnTag_WeakPwd 23587
#define kOperatorBtnTag_UpdateDevice 23588
#define kOperatorBtnTag_initDevicePwd 23589

@implementation ContactCell

-(void)dealloc{
    [self.headView release];
    [self.typeView release];
    [self.nameLabel release];
    [self.stateLabel release];
    [self.contact release];
    [self.weakPwdButton release];
    [self.messageCountView release];
    [self.defenceStateView release];
    [self.topView release];
    [self.lineView release];
    [self.bottomView release];
    [self.btnNormalImg release];
    [self.updateDeviceBtn release];
    [self.initDeviceButton release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark 重写setFrame方法，自己调整cell的frame
#define kTableTopBorderWidth 10.0
#define kTableViewCellMargin 10.0
- (void)setFrame:(CGRect)frame
{
    // 更改顶部间距、每个cell之间的间距
//    frame.origin.y += kTableTopBorderWidth;
//    frame.size.height -= kTableViewCellMargin;
    
    [super setFrame:frame];
}

#define LINEVIEW_HEIGHT_BETWEEN_TOPVIEW_AND_BOTTOMVIEW 0.5
#define CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT 16
#define CONTACT_STATE_LABEL_WIDTH 50
#define MESSAHE_COUNT_VIEW_WIDTH_AND_HEIGHT 24
#define HEADER_ICON_VIEW_HEIGHT_WIDTH 50
#define DEFENCE_STATE_VIEW_WIDTH_HEIGHT 24
-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.backgroundView.frame.size.width;
    CGFloat height = self.backgroundView.frame.size.height-10.0;
    
    
    //view1
    if (!self.topView) {
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, (height-LINEVIEW_HEIGHT_BETWEEN_TOPVIEW_AND_BOTTOMVIEW)*2/3)];
        [self.contentView addSubview:topView];
        self.topView = topView;
        [topView release];
    }else{
        self.topView.frame = CGRectMake(0.0, 0.0, width, (height-LINEVIEW_HEIGHT_BETWEEN_TOPVIEW_AND_BOTTOMVIEW)*2/3);
    }
    
    
    CGFloat headView_x = 5.0;
    CGFloat headView_y = 5.0;
    if(!self.headView){
        UIButton *headButton = [[UIButton alloc] initWithFrame:CGRectMake(headView_x, headView_y, (self.topView.frame.size.height-headView_y*2)*4/3,self.topView.frame.size.height-headView_y*2)];
        
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, headButton.frame.size.width ,headButton.frame.size.height)];
        NSString *filePath = [Utils getHeaderFilePathWithId:self.contact.contactId];
        UIImage *headImg = [UIImage imageWithContentsOfFile:filePath];
        if(headImg==nil){
            headImg = [UIImage imageNamed:@"ic_header.png"];
        }
        headImg = [headImg stretchableImageWithLeftCapWidth:headImg.size.width*0.5 topCapHeight:headImg.size.height*0.5];
        headImageView.image = headImg;
        headImageView.contentMode = UIViewContentModeScaleAspectFit;
        [headButton addSubview:headImageView];
        
        UIImageView *headIconView = [[UIImageView alloc] initWithFrame:CGRectMake((headButton.frame.size.width-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, (headButton.frame.size.height-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, HEADER_ICON_VIEW_HEIGHT_WIDTH, HEADER_ICON_VIEW_HEIGHT_WIDTH)];
        headIconView.image = [UIImage imageNamed:@"ic_header_play.png"];
        [headButton addSubview:headIconView];
        if(self.contact.contactType==CONTACT_TYPE_UNKNOWN||self.contact.contactType==CONTACT_TYPE_PHONE){
            [headIconView setHidden:YES];
        }else{
            [headIconView setHidden:NO];
        }
        [headIconView release];
        
        [self.topView addSubview:headButton];
        self.headView = headButton;
        [headButton release];
        [headImageView release];
    }else{
        
        self.headView.frame = CGRectMake(headView_x, headView_y, (self.topView.frame.size.height-headView_y*2)*4/3,self.topView.frame.size.height-headView_y*2);
        
        NSString *filePath = [Utils getHeaderFilePathWithId:self.contact.contactId];
        UIImage *headImg = [UIImage imageWithContentsOfFile:filePath];
        if(headImg==nil){
            headImg = [UIImage imageNamed:@"ic_header.png"];
        }
        UIImageView *headImageView = [[self.headView subviews] objectAtIndex:0];
        headImageView.frame = CGRectMake(0.0, 0.0, self.headView.frame.size.width ,self.headView.frame.size.height);
        headImageView.image = headImg;
        headImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImageView *headIconView = [[self.headView subviews] objectAtIndex:1];
        headIconView.frame = CGRectMake((self.headView.frame.size.width-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, (self.headView.frame.size.height-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, HEADER_ICON_VIEW_HEIGHT_WIDTH, HEADER_ICON_VIEW_HEIGHT_WIDTH);
        if(self.contact.contactType==CONTACT_TYPE_UNKNOWN||self.contact.contactType==CONTACT_TYPE_PHONE){
            [headIconView setHidden:YES];
        }else{
            [headIconView setHidden:NO];
        }
        
        
    }
    [self.headView addTarget:self action:@selector(onHeadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGFloat space_header_name = 10.0;
    if(!self.nameLabel){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width+space_header_name ,6.0,self.topView.frame.size.width-(self.topView.frame.size.height-6.0*2)*4/3-10*2-CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT-10*2,self.topView.frame.size.height/2-6.0)];
        
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_18];
        
        textLabel.text = self.contact.contactName;
        
        [self.topView addSubview:textLabel];
        self.nameLabel = textLabel;
        [textLabel release];
    }else{
        self.nameLabel.frame = CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width+space_header_name ,6.0,self.topView.frame.size.width-(self.topView.frame.size.height-6.0*2)*4/3-10*2-CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT-10*2,self.topView.frame.size.height/2-6.0);
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = XBlack;
        self.nameLabel.backgroundColor = XBGAlpha;
        [self.nameLabel setFont:XFontBold_18];
        
        self.nameLabel.text = self.contact.contactName;
        
        [self.topView addSubview:self.nameLabel];
    }
    
    
    CGFloat space_header_type = 10.0;
    if(!self.typeView){
        UIImageView *typeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width+space_header_type, self.topView.frame.size.height/2+6.0, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT)];
        if(self.contact.contactType==CONTACT_TYPE_NPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_npc.png"];
            typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_IPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_ipc.png"];
            typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_PHONE){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_phone.png"];
            typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_DOORBELL){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_doorbell.png"];
            typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_UNKNOWN){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_unknown.png"];
            typeView.image = typeImg;
        }
        
        [self.topView addSubview:typeView];
        self.typeView = typeView;
        
    }else{
        self.typeView.frame = CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width+space_header_type, self.topView.frame.size.height/2+6.0, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT);
        
        if(self.contact.contactType==CONTACT_TYPE_NPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_npc.png"];
            self.typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_IPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_ipc.png"];
            self.typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_PHONE){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_phone.png"];
            self.typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_DOORBELL){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_doorbell.png"];
            self.typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_UNKNOWN){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_unknown.png"];
            self.typeView.image = typeImg;
        }
        
        [self.topView addSubview:self.typeView];
    }
    
    
    CGFloat space_type_state = 5.0;
    CGFloat stateLabel_w = [Utils getStringWidthWithString:NSLocalizedString(@"offline", nil) font:XFontBold_14 maxWidth:width];
    CGFloat stateLabel_h = [Utils getStringHeightWithString:NSLocalizedString(@"offline", nil) font:XFontBold_14 maxWidth:width];
    if(!self.stateLabel){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.typeView.frame.origin.x+self.typeView.frame.size.width+space_type_state,self.typeView.frame.origin.y,stateLabel_w,stateLabel_h)];
        
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_14];
        if (self.contact.isGettingOnLineState) {//isGettingOnLineState
            textLabel.text = @"";
        }else{
            if(self.contact.onLineState==STATE_ONLINE){
                
                textLabel.textColor = XBlue;
                textLabel.text = NSLocalizedString(@"online", nil);
            }else{
                textLabel.textColor = XBlack;
                textLabel.text = NSLocalizedString(@"offline", nil);
            }
        }
        [self.topView addSubview:textLabel];
        self.stateLabel = textLabel;
        [textLabel release];
    }else{
        self.stateLabel.frame = CGRectMake(self.typeView.frame.origin.x+self.typeView.frame.size.width+space_type_state,self.typeView.frame.origin.y,stateLabel_w,stateLabel_h);
        self.stateLabel.textAlignment = NSTextAlignmentLeft;
        self.stateLabel.backgroundColor = XBGAlpha;
        [self.stateLabel setFont:XFontBold_14];
        
        if (self.contact.isGettingOnLineState) {//isGettingOnLineState
            self.stateLabel.text = @"";
        }else{
            if(self.contact.onLineState==STATE_ONLINE){
                
                self.stateLabel.textColor = XBlue;
                self.stateLabel.text = NSLocalizedString(@"online", nil);
            }else{
                self.stateLabel.textColor = XBlack;
                self.stateLabel.text = NSLocalizedString(@"offline", nil);
            }
        }
        
        [self.topView addSubview:self.stateLabel];
    }
    
    
    if(!self.messageCountView){
        UIImageView *messageCountView = [[UIImageView alloc] initWithFrame:CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width, self.headView.frame.origin.y+3, MESSAHE_COUNT_VIEW_WIDTH_AND_HEIGHT, MESSAHE_COUNT_VIEW_WIDTH_AND_HEIGHT)];
        messageCountView.image = [UIImage imageNamed:@"bg_message_count.png"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, messageCountView.frame.size.width, messageCountView.frame.size.height-5)];
        if(self.contact.messageCount>10){
            label.text = @"10+";
        }else{
            label.text = [NSString stringWithFormat:@"%i",self.contact.messageCount];
        }
        
        label.textAlignment = NSTextAlignmentCenter;
        label.font = XFontBold_12;
        label.backgroundColor = XBGAlpha;
        label.textColor = XWhite;
        [messageCountView addSubview:label];
        [label release];
        
        self.messageCountView = messageCountView;
        //        [self.contentView addSubview:messageCountView];
        [messageCountView release];
        
        if(self.contact.messageCount>0){
            [self.messageCountView setHidden:NO];
        }else{
            [self.messageCountView setHidden:YES];
        }
    }else{
        self.messageCountView.frame = CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width, self.headView.frame.origin.y+3, MESSAHE_COUNT_VIEW_WIDTH_AND_HEIGHT, MESSAHE_COUNT_VIEW_WIDTH_AND_HEIGHT);
        
        UILabel *label = [self.messageCountView.subviews objectAtIndex:0];
        label.frame = CGRectMake(0, 0, self.messageCountView.frame.size.width, self.messageCountView.frame.size.height-5);
        if(self.contact.messageCount>10){
            label.text = @"10+";
        }else{
            label.text = [NSString stringWithFormat:@"%i",self.contact.messageCount];
        }
        
        
        //        [self.contentView addSubview:self.messageCountView];
        if(self.contact.messageCount>0){
            [self.messageCountView setHidden:NO];
        }else{
            [self.messageCountView setHidden:YES];
        }
    }
    
    
    if(!self.defenceStateView){
        UIButton *defenceStateView = [UIButton buttonWithType:UIButtonTypeCustom];
        defenceStateView.frame = CGRectMake(self.topView.frame.size.width-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20, (self.topView.frame.size.height-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20)/2, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, defenceStateView.frame.size.width-20, defenceStateView.frame.size.height-20)];
        
        
        switch(self.contact.defenceState){
            case DEFENCE_STATE_ON:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_on.png"];
            }
                break;
                
            case DEFENCE_STATE_OFF:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_off.png"];
            }
                break;
                
            case DEFENCE_STATE_LOADING:
            {
                
            }
                break;
                
            case DEFENCE_STATE_WARNING_NET:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_warning.png"];
            }
                break;
                
            case DEFENCE_STATE_WARNING_PWD:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_warning.png"];
            }
                break;
            case DEFENCE_STATE_NO_PERMISSION:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_limit.png"];
            }
                break;
        }
        
        
        [defenceStateView addSubview:imageView];
        [imageView release];
        self.defenceStateView = defenceStateView;
        [self.topView addSubview:self.defenceStateView];
        
        
    }else{
        self.defenceStateView.frame = CGRectMake(self.topView.frame.size.width-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20, (self.topView.frame.size.height-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20)/2, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20);
        UIImageView *imageView = [[self.defenceStateView subviews] objectAtIndex:0];
        imageView.frame = CGRectMake(10, 10, self.defenceStateView.frame.size.width-20, self.defenceStateView.frame.size.height-20);
        
        switch(self.contact.defenceState){
            case DEFENCE_STATE_ON:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_on.png"];
            }
                break;
                
            case DEFENCE_STATE_OFF:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_off.png"];
            }
                break;
                
            case DEFENCE_STATE_LOADING:
            {
                
            }
                break;
                
            case DEFENCE_STATE_WARNING_NET:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_warning.png"];
            }
                break;
                
            case DEFENCE_STATE_WARNING_PWD:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_warning.png"];
            }
                break;
            case DEFENCE_STATE_NO_PERMISSION:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_limit.png"];
            }
                break;
        }
        
        [self.topView addSubview:self.defenceStateView];
        
    }
    
    if(!self.defenceProgressView){
        YProgressView *progressView = [[YProgressView alloc] initWithFrame:CGRectMake(self.topView.frame.size.width-10-DEFENCE_STATE_VIEW_WIDTH_HEIGHT, (self.topView.frame.size.height-DEFENCE_STATE_VIEW_WIDTH_HEIGHT)/2, DEFENCE_STATE_VIEW_WIDTH_HEIGHT, DEFENCE_STATE_VIEW_WIDTH_HEIGHT)];
        progressView.backgroundView.image = [UIImage imageNamed:@"ic_progress_arrow.png"];
        
        self.defenceProgressView = progressView;
        [progressView release];
        [self.topView addSubview:self.defenceProgressView];
        
        
    }else{
        self.defenceProgressView.frame = CGRectMake(self.topView.frame.size.width-10-DEFENCE_STATE_VIEW_WIDTH_HEIGHT, (self.topView.frame.size.height-DEFENCE_STATE_VIEW_WIDTH_HEIGHT)/2, DEFENCE_STATE_VIEW_WIDTH_HEIGHT, DEFENCE_STATE_VIEW_WIDTH_HEIGHT);
        self.defenceProgressView.backgroundView.image = [UIImage imageNamed:@"ic_progress_arrow.png"];
        [self.topView addSubview:self.defenceProgressView];
    }
    
    
    [self updateDefenceStateView];
    [self.defenceStateView addTarget:self action:@selector(onDefencePress:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //弱密码提示
    //弱密码按钮与布防撤防按钮之间的距离
    CGFloat space_weakPwdImage_defenceBtn = 5.0;
    //弱密码按钮的宽、高
    CGFloat weakPwdButton_w = width;
    CGFloat weakPwdButton_h = height;
    //按钮图片的宽、高
    CGFloat weakPwdImageView_w = 20.0;
    CGFloat weakPwdImageView_h = weakPwdImageView_w*(40/31);
    if(!self.weakPwdButton){
        UIButton *weakPwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        weakPwdButton.frame = CGRectMake(0.0 ,0.0 ,weakPwdButton_w,weakPwdButton_h);
        weakPwdButton.tag = kOperatorBtnTag_WeakPwd;
        [weakPwdButton addTarget:self action:@selector(onOperatorItemPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:weakPwdButton];
        self.weakPwdButton = weakPwdButton;
        
        UIImageView *weakPwdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.defenceStateView.frame.origin.x-weakPwdImageView_w-space_weakPwdImage_defenceBtn, (self.topView.frame.size.height-weakPwdImageView_h)/2 ,weakPwdImageView_w,weakPwdImageView_h)];
        weakPwdImageView.image = [UIImage imageNamed:@"ic_contact_weak_pwd.png"];
        [self.weakPwdButton addSubview:weakPwdImageView];
        [weakPwdImageView release];
    }
    
    if(self.contact.defenceState == DEFENCE_STATE_ON || self.contact.defenceState == DEFENCE_STATE_OFF){
        //密码的第一位为0，则表示是加密过的，为非弱密码
        //因为设备密码的第一位不为0
        NSString *weakPwd = [self.contact.contactPassword substringToIndex:1];
        if (![weakPwd isEqualToString:@"0"]) {//弱（红）
            [self.weakPwdButton setHidden:NO];
        }else{
            [self.weakPwdButton setHidden:YES];
        }
        
    }else{
        [self.weakPwdButton setHidden:YES];
    }
    
    
    //设备列表的设备已经被初始化，点击按钮跳转到初始化密码界面
    //按钮的宽、高
    CGFloat initDeviceButton_w = width;
    CGFloat initDeviceButton_h = height;
    if(!self.initDeviceButton){
        UIButton *initDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        initDeviceButton.frame = CGRectMake(0.0 ,0.0 ,initDeviceButton_w,initDeviceButton_h);
        initDeviceButton.tag = kOperatorBtnTag_initDevicePwd;
        [initDeviceButton addTarget:self action:@selector(onOperatorItemPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:initDeviceButton];
        self.initDeviceButton = initDeviceButton;
    }
    BOOL isInitedDevice = NO;//YES表示密码为空，点击cell时跳转到设置密码界面
    NSArray* deviceList = [[UDPManager sharedDefault] getLanDevices];
    for (LocalDevice *localDevice in deviceList) {
        if ([localDevice.contactId isEqualToString:self.contact.contactId]&&localDevice.flag==0) {
            isInitedDevice = YES;
            break;
        }
    }
    if(isInitedDevice){
        [self.initDeviceButton setHidden:NO];
        
    }else{
        [self.initDeviceButton setHidden:YES];
    }
    
    
    //设备检查更新按钮图标
    //的宽、高
    //按钮以及按钮图片的宽、高
    CGFloat updateDeviceBtn_wh = 40.0;
    if(!self.updateDeviceBtn){
        UIButton *updateDeviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        updateDeviceBtn.frame = CGRectMake(width-updateDeviceBtn_wh ,0.0 ,updateDeviceBtn_wh,updateDeviceBtn_wh);
        updateDeviceBtn.backgroundColor = XBGAlpha;
        updateDeviceBtn.tag = kOperatorBtnTag_UpdateDevice;
        [updateDeviceBtn addTarget:self action:@selector(onOperatorItemPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:updateDeviceBtn];
        self.updateDeviceBtn = updateDeviceBtn;
        
        UIImageView *updateDeviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0 ,updateDeviceBtn_wh,updateDeviceBtn_wh)];
        updateDeviceImageView.backgroundColor = XBGAlpha;
        updateDeviceImageView.image = [UIImage imageNamed:@"ic_contact_update_device.png"];
        [self.updateDeviceBtn addSubview:updateDeviceImageView];
        [updateDeviceImageView release];
    }
    //isNewVersionDevice为YES表示设备可升级到新版本
    if(self.contact.isNewVersionDevice && (self.contact.defenceState == DEFENCE_STATE_ON || self.contact.defenceState == DEFENCE_STATE_OFF)){
        [self.updateDeviceBtn setHidden:NO];
        CGRect rect1 = self.defenceStateView.frame;
        rect1.origin.y += 20.0;
        self.defenceStateView.frame = rect1;
        CGRect rect2 = self.defenceProgressView.frame;
        rect2.origin.y += 20.0;
        self.defenceProgressView.frame = rect2;
    }else{
        [self.updateDeviceBtn setHidden:YES];
    }
    
    
    //topView与bottomView之间的分隔线
    if (!self.lineView) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.topView.frame.origin.y+self.topView.frame.size.height, width, LINEVIEW_HEIGHT_BETWEEN_TOPVIEW_AND_BOTTOMVIEW)];
        lineView.backgroundColor = UIColorFromRGB(0xd1d1d1);
        [self.contentView addSubview:lineView];
        self.lineView = lineView;
        [lineView release];
    }else{
        self.lineView.frame = CGRectMake(0.0, self.topView.frame.origin.y+self.topView.frame.size.height, width, LINEVIEW_HEIGHT_BETWEEN_TOPVIEW_AND_BOTTOMVIEW);
    }
    
    
    
    //防止cell重利用引起的问题，所以在此作一个remove操作
    if (self.bottomView) {
        [self.bottomView removeFromSuperview];
    }
    //view2
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.lineView.frame.origin.y+self.lineView.frame.size.height, width, (height-LINEVIEW_HEIGHT_BETWEEN_TOPVIEW_AND_BOTTOMVIEW)*1/3)];
    [self.contentView addSubview:bottomView];
    self.bottomView = bottomView;
    [bottomView release];
    
    //通话、回放、设置和修改按钮
    int count = 0;//4（NPC）、3（IPC、DOORBELL、IP添加设备）、1
    //按钮文字的宽
    CGFloat btnTextChatWidth = [Utils getStringWidthWithString:NSLocalizedString(@"chat", nil) font:XFontBold_12 maxWidth:width];
    CGFloat btnTextPlaybackWidth = [Utils getStringWidthWithString:NSLocalizedString(@"playback", nil) font:XFontBold_12 maxWidth:width];
    CGFloat btnTextControlWidth = [Utils getStringWidthWithString:NSLocalizedString(@"control", nil) font:XFontBold_12 maxWidth:width];
    CGFloat btnTextModifyWidth = [Utils getStringWidthWithString:NSLocalizedString(@"modify", nil) font:XFontBold_12 maxWidth:width];
    switch(self.contact.contactType){
        case CONTACT_TYPE_PHONE:
        {
            count = 3;
        }
            break;
        case CONTACT_TYPE_DOORBELL:
        case CONTACT_TYPE_IPC:
        {
            count = 3;
            //分隔线的宽
            CGFloat btnSpace = 0.5;
            //按钮的宽、高
            CGFloat btnWidth = (self.bottomView.frame.size.width-btnSpace*(count-1))/count;
            CGFloat btnHeight = self.bottomView.frame.size.height;
            //按钮图片与文字之间的距离
            CGFloat space_img_text = 5.0;
            //按钮图片的宽、高
            CGFloat btnImageH = 12.0;
            CGFloat btnImageW = btnImageH*(32.0/27.0);
            //按钮文字的高
            CGFloat btnTextHeight = btnHeight;
            for(int i=0;i<count;i++){
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(i*(btnWidth+btnSpace), 0, btnWidth, btnHeight);
                [button addTarget:self action:@selector(onOperatorItemPress:) forControlEvents:UIControlEventTouchUpInside];
                [button addTarget:self action:@selector(onTouchDownToClickBtn:) forControlEvents:UIControlEventTouchDown];
                [self.bottomView addSubview:button];
                
                //按钮之间的分隔线
                if (i!=0) {
                    UIView *btnLineView = [[UIView alloc] initWithFrame:CGRectMake(btnWidth*i, 0.0, btnSpace, btnHeight)];
                    btnLineView.backgroundColor = UIColorFromRGB(0xd1d1d1);
                    [self.bottomView addSubview:btnLineView];
                    [btnLineView release];
                }
                
                if(i==0){
                    button.tag = kOperatorBtnTag_Playback;
                    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextPlaybackWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                    iconView.image = [UIImage imageNamed:@"ic_operator_item_playback.png"];
                    [button addSubview:iconView];
                    [iconView release];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextPlaybackWidth, btnTextHeight)];
                    label.textColor = UIColorFromRGB_A(0x000000,0.75);
                    label.backgroundColor = XBGAlpha;
                    [label setFont:XFontBold_12];
                    label.text = NSLocalizedString(@"playback", nil);
                    [button addSubview: label];
                    [label release];
                }else if(i==1){
                    button.tag = kOperatorBtnTag_Control;
                    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextControlWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                    iconView.image = [UIImage imageNamed:@"ic_operator_item_control.png"];
                    [button addSubview:iconView];
                    [iconView release];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextControlWidth, btnTextHeight)];
                    label.textColor = UIColorFromRGB_A(0x000000,0.75);
                    label.backgroundColor = XBGAlpha;
                    [label setFont:XFontBold_12];
                    label.text = NSLocalizedString(@"control", nil);
                    [button addSubview: label];
                    [label release];
                }else if(i==2){
                    button.tag = kOperatorBtnTag_Modify;
                    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextModifyWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                    iconView.image = [UIImage imageNamed:@"ic_operator_item_modify.png"];
                    [button addSubview:iconView];
                    [iconView release];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextModifyWidth, btnTextHeight)];
                    label.textColor = UIColorFromRGB_A(0x000000,0.75);
                    label.backgroundColor = XBGAlpha;
                    [label setFont:XFontBold_12];
                    label.text = NSLocalizedString(@"modify", nil);
                    [button addSubview: label];
                    [label release];
                }
            }
        }
            break;
        case CONTACT_TYPE_NPC:
        {
            count = 4;
            //分隔线的宽
            CGFloat btnSpace = 0.5;
            //按钮的宽、高
            CGFloat btnWidth = (self.bottomView.frame.size.width-btnSpace*(count-1))/count;
            CGFloat btnHeight = self.bottomView.frame.size.height;
            //按钮图片与文字之间的距离
            CGFloat space_img_text = 5.0;
            //按钮图片的宽、高
            CGFloat btnImageH = 12.0;
            CGFloat btnImageW = btnImageH*(32.0/27.0);
            //按钮文字的高
            CGFloat btnTextHeight = btnHeight;
            for(int i=0;i<count;i++){
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(i*(btnWidth+btnSpace), 0, btnWidth, btnHeight);
                [button addTarget:self action:@selector(onOperatorItemPress:) forControlEvents:UIControlEventTouchUpInside];
                [button addTarget:self action:@selector(onTouchDownToClickBtn:) forControlEvents:UIControlEventTouchDown];
                [self.bottomView addSubview:button];
                
                //按钮之间的分隔线
                if (i!=0) {
                    UIView *btnLineView = [[UIView alloc] initWithFrame:CGRectMake(btnWidth*i, 0.0, btnSpace, btnHeight)];
                    btnLineView.backgroundColor = UIColorFromRGB(0xd1d1d1);
                    [self.bottomView addSubview:btnLineView];
                    [btnLineView release];
                }
                
                if(i==0){
                    button.tag = kOperatorBtnTag_Chat;
                    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextChatWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                    iconView.image = [UIImage imageNamed:@"ic_operator_item_chat.png"];
                    [button addSubview:iconView];
                    [iconView release];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextChatWidth, btnTextHeight)];
                    label.textColor = UIColorFromRGB_A(0x000000,0.75);
                    label.backgroundColor = XBGAlpha;
                    [label setFont:XFontBold_12];
                    label.text = NSLocalizedString(@"chat", nil);
                    [button addSubview: label];
                    [label release];
                }else if(i==1){
                    button.tag = kOperatorBtnTag_Playback;
                    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextPlaybackWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                    iconView.image = [UIImage imageNamed:@"ic_operator_item_playback.png"];
                    [button addSubview:iconView];
                    [iconView release];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextPlaybackWidth, btnTextHeight)];
                    label.textColor = UIColorFromRGB_A(0x000000,0.75);
                    label.backgroundColor = XBGAlpha;
                    [label setFont:XFontBold_12];
                    label.text = NSLocalizedString(@"playback", nil);
                    [button addSubview: label];
                    [label release];
                }else if(i==2){
                    button.tag = kOperatorBtnTag_Control;
                    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextControlWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                    iconView.image = [UIImage imageNamed:@"ic_operator_item_control.png"];
                    [button addSubview:iconView];
                    [iconView release];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextControlWidth, btnTextHeight)];
                    label.textColor = UIColorFromRGB_A(0x000000,0.75);
                    label.backgroundColor = XBGAlpha;
                    [label setFont:XFontBold_12];
                    label.text = NSLocalizedString(@"control", nil);
                    [button addSubview: label];
                    [label release];
                }else if(i==3){
                    button.tag = kOperatorBtnTag_Modify;
                    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextModifyWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                    iconView.image = [UIImage imageNamed:@"ic_operator_item_modify.png"];
                    [button addSubview:iconView];
                    [iconView release];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextModifyWidth, btnTextHeight)];
                    label.textColor = UIColorFromRGB_A(0x000000,0.75);
                    label.backgroundColor = XBGAlpha;
                    [label setFont:XFontBold_12];
                    label.text = NSLocalizedString(@"modify", nil);
                    [button addSubview: label];
                    [label release];
                }
            }
        }
            break;
        default:
        {
            if(self.contact.contactId.intValue<256){//IP添加设备
                count = 3;//IP添加设备
                //分隔线的宽
                CGFloat btnSpace = 0.5;
                //按钮的宽、高
                CGFloat btnWidth = (self.bottomView.frame.size.width-btnSpace*(count-1))/count;
                CGFloat btnHeight = self.bottomView.frame.size.height;
                //按钮图片与文字之间的距离
                CGFloat space_img_text = 5.0;
                //按钮图片的宽、高
                CGFloat btnImageH = 12.0;
                CGFloat btnImageW = btnImageH*(32.0/27.0);
                //按钮文字的高
                CGFloat btnTextHeight = btnHeight;
                for(int i=0;i<count;i++){
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(i*(btnWidth+btnSpace), 0, btnWidth, btnHeight);
                    [button addTarget:self action:@selector(onOperatorItemPress:) forControlEvents:UIControlEventTouchUpInside];
                    [button addTarget:self action:@selector(onTouchDownToClickBtn:) forControlEvents:UIControlEventTouchDown];
                    [self.bottomView addSubview:button];
                    
                    //按钮之间的分隔线
                    if (i!=0) {
                        UIView *btnLineView = [[UIView alloc] initWithFrame:CGRectMake(btnWidth*i, 0.0, btnSpace, btnHeight)];
                        btnLineView.backgroundColor = UIColorFromRGB(0xd1d1d1);
                        [self.bottomView addSubview:btnLineView];
                        [btnLineView release];
                    }
                    
                    if(i==0){
                        button.tag = kOperatorBtnTag_Playback;
                        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextPlaybackWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                        iconView.image = [UIImage imageNamed:@"ic_operator_item_playback.png"];
                        [button addSubview:iconView];
                        [iconView release];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextPlaybackWidth, btnTextHeight)];
                        label.textColor = UIColorFromRGB_A(0x000000,0.75);
                        label.backgroundColor = XBGAlpha;
                        [label setFont:XFontBold_12];
                        label.text = NSLocalizedString(@"playback", nil);
                        [button addSubview: label];
                        [label release];
                    }else if(i==1){
                        button.tag = kOperatorBtnTag_Control;
                        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextControlWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                        iconView.image = [UIImage imageNamed:@"ic_operator_item_control.png"];
                        [button addSubview:iconView];
                        [iconView release];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextControlWidth, btnTextHeight)];
                        label.textColor = UIColorFromRGB_A(0x000000,0.75);
                        label.backgroundColor = XBGAlpha;
                        [label setFont:XFontBold_12];
                        label.text = NSLocalizedString(@"control", nil);
                        [button addSubview: label];
                        [label release];
                    }else if(i==2){
                        button.tag = kOperatorBtnTag_Modify;
                        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextModifyWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                        iconView.image = [UIImage imageNamed:@"ic_operator_item_modify.png"];
                        [button addSubview:iconView];
                        [iconView release];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextModifyWidth, btnTextHeight)];
                        label.textColor = UIColorFromRGB_A(0x000000,0.75);
                        label.backgroundColor = XBGAlpha;
                        [label setFont:XFontBold_12];
                        label.text = NSLocalizedString(@"modify", nil);
                        [button addSubview: label];
                        [label release];
                    }
                }
            }else{
                count = 3;//IP添加设备
                //分隔线的宽
                CGFloat btnSpace = 0.5;
                //按钮的宽、高
                CGFloat btnWidth = (self.bottomView.frame.size.width-btnSpace*(count-1))/count;
                CGFloat btnHeight = self.bottomView.frame.size.height;
                //按钮图片与文字之间的距离
                CGFloat space_img_text = 5.0;
                //按钮图片的宽、高
                CGFloat btnImageH = 12.0;
                CGFloat btnImageW = btnImageH*(32.0/27.0);
                //按钮文字的高
                CGFloat btnTextHeight = btnHeight;
                for(int i=0;i<count;i++){
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(i*(btnWidth+btnSpace), 0, btnWidth, btnHeight);
                    [button addTarget:self action:@selector(onOperatorItemPress:) forControlEvents:UIControlEventTouchUpInside];
                    [button addTarget:self action:@selector(onTouchDownToClickBtn:) forControlEvents:UIControlEventTouchDown];
                    [self.bottomView addSubview:button];
                    
                    //按钮之间的分隔线
                    if (i!=0) {
                        UIView *btnLineView = [[UIView alloc] initWithFrame:CGRectMake(btnWidth*i, 0.0, btnSpace, btnHeight)];
                        btnLineView.backgroundColor = UIColorFromRGB(0xd1d1d1);
                        [self.bottomView addSubview:btnLineView];
                        [btnLineView release];
                    }
                    
                    if(i==0){
                        button.enabled = NO;
                        button.tag = kOperatorBtnTag_Playback;
                        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextPlaybackWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                        iconView.image = [UIImage imageNamed:@"ic_operator_item_playback_unknown_type.png"];
                        [button addSubview:iconView];
                        [iconView release];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextPlaybackWidth, btnTextHeight)];
                        label.textColor = UIColorFromRGB_A(0x000000,0.75);
                        label.backgroundColor = XBGAlpha;
                        [label setFont:XFontBold_12];
                        label.text = NSLocalizedString(@"playback", nil);
                        [button addSubview: label];
                        [label release];
                    }else if(i==1){
                        button.enabled = NO;
                        button.tag = kOperatorBtnTag_Control;
                        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextControlWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                        iconView.image = [UIImage imageNamed:@"ic_operator_item_control_unknown_type.png"];
                        [button addSubview:iconView];
                        [iconView release];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextControlWidth, btnTextHeight)];
                        label.textColor = UIColorFromRGB_A(0x000000,0.75);
                        label.backgroundColor = XBGAlpha;
                        [label setFont:XFontBold_12];
                        label.text = NSLocalizedString(@"control", nil);
                        [button addSubview: label];
                        [label release];
                    }else if(i==2){
                        button.tag = kOperatorBtnTag_Modify;
                        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-btnImageW-btnTextModifyWidth-space_img_text)/2, (btnHeight-btnImageH)/2, btnImageW, btnImageH)];
                        iconView.image = [UIImage imageNamed:@"ic_operator_item_modify.png"];
                        [button addSubview:iconView];
                        [iconView release];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x+iconView.frame.size.width+space_img_text, 0.0, btnTextModifyWidth, btnTextHeight)];
                        label.textColor = UIColorFromRGB_A(0x000000,0.75);
                        label.backgroundColor = XBGAlpha;
                        [label setFont:XFontBold_12];
                        label.text = NSLocalizedString(@"modify", nil);
                        [button addSubview: label];
                        [label release];
                    }
                }
            }
        }
    }
    
    
    //弱密码按钮提前
    [self.contentView bringSubviewToFront:self.weakPwdButton];
    [self.contentView insertSubview:self.initDeviceButton belowSubview:self.weakPwdButton];
}

-(void)willTransitionToState:(UITableViewCellStateMask)state{
    if (state == UITableViewCellStateShowingDeleteConfirmationMask) {
        //cell进入delete编辑状态时，不可以点击弱密码按钮和空密码按钮
        [self.weakPwdButton setEnabled:NO];
        [self.initDeviceButton setEnabled:NO];
    }else{
        //cell退出delete编辑状态时，可以点击弱密码按钮和空密码按钮
        [self.weakPwdButton setEnabled:YES];
        [self.initDeviceButton setEnabled:YES];
    }
}

#pragma mark - 监听按钮按下时，将图片和文字显示成按下的状态；并且在放开按钮时，恢复
-(void)onTouchDownToClickBtn:(UIButton*)button{
    
    //根据tag获取相应按钮的按下状态图片
    UIImage *btnDownImg = nil;
    if (button.tag == kOperatorBtnTag_Chat) {
        btnDownImg = [UIImage imageNamed:@"ic_operator_item_chat_p.png"];
    }else if(button.tag == kOperatorBtnTag_Playback){
        btnDownImg = [UIImage imageNamed:@"ic_operator_item_playback_p.png"];
    }else if(button.tag == kOperatorBtnTag_Control){
        btnDownImg = [UIImage imageNamed:@"ic_operator_item_control_p.png"];
    }else if(button.tag == kOperatorBtnTag_Modify){
        btnDownImg = [UIImage imageNamed:@"ic_operator_item_modify_p.png"];
    }
    
    
    //设置按钮按下时，要显示的图片和文字颜色
    for (id obj in button.subviews) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView *iconView = (UIImageView *)obj;
            //设置之前，临时保存未按下时，按钮当前显示的图片；将用于松开按钮时，恢复
            self.btnNormalImg = iconView.image;
            iconView.image = btnDownImg;
        }
        if ([obj isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)obj;
            label.textColor = UIColorFromRGB_A(0x000000,0.85);
        }
    }
}

#pragma mark - 通话、回放、设置和修改按钮
-(void)onOperatorItemPress:(id)sender{
    UIButton *button = (UIButton*)sender;
    
    //设置按钮松开时，要显示的图片和文字颜色
    if (button.tag!=kOperatorBtnTag_WeakPwd && button.tag!=kOperatorBtnTag_UpdateDevice && button.tag!=kOperatorBtnTag_initDevicePwd) {
        for (id obj in button.subviews) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *iconView = (UIImageView *)obj;
                iconView.image = self.btnNormalImg;
            }
            if ([obj isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)obj;
                label.textColor = UIColorFromRGB_A(0x000000,0.75);
            }
        }
    }
    
    if (self.delegate) {
        [self.delegate ContactCellOnClickBottomBtn:button.tag contact:self.contact];
    }
}

-(void)onHeadClick:(id)sender{
    DLog(@"HEAD CLICK");
    if (self.delegate) {
        [self.delegate onClick:self.position contact:self.contact];
    }
}

-(void)onDefencePress:(UIButton*)button{
    //UIImageView *imageView = [[button subviews] objectAtIndex:0];
    [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:self.contact.contactId isClick:YES];
    if(self.contact.defenceState==DEFENCE_STATE_WARNING_NET||self.contact.defenceState==DEFENCE_STATE_WARNING_PWD){
        self.contact.defenceState = DEFENCE_STATE_LOADING;
        [self updateDefenceStateView];
        [[P2PClient sharedClient] getDefenceState:self.contact.contactId password:self.contact.contactPassword];
        
    }else if(self.contact.defenceState==DEFENCE_STATE_ON){
        self.contact.defenceState = DEFENCE_STATE_LOADING;
        [self updateDefenceStateView];
        [[P2PClient sharedClient] setRemoteDefenceWithId:self.contact.contactId password:self.contact.contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_OFF];
    }else if(self.contact.defenceState==DEFENCE_STATE_OFF){
        self.contact.defenceState = DEFENCE_STATE_LOADING;
        [self updateDefenceStateView];
        [[P2PClient sharedClient] setRemoteDefenceWithId:self.contact.contactId password:self.contact.contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_ON];
    }
}

-(void)updateDefenceStateView{
    if(self.contact.onLineState==STATE_ONLINE){
        if(self.contact.defenceState==DEFENCE_STATE_LOADING){
            [self.defenceStateView setHidden:YES];
            [self.defenceProgressView setHidden:NO];
            [self.defenceProgressView start];
            
        }else{
            [self.defenceStateView setHidden:NO];
            [self.defenceProgressView setHidden:YES];
            [self.defenceProgressView stop];
        }
        
    }else{
        [self.defenceStateView setHidden:YES];
        [self.defenceProgressView setHidden:YES];
        [self.defenceProgressView stop];
    }
}

@end
