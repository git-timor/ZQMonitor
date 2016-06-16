//
//  ChatCell.h
//  Yoosee
//
//  Created by guojunyi on 14-5-29.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class P2PMessage;
@interface ChatCell : UITableViewCell

@property (strong, nonatomic) P2PMessage *message;


@property (strong, nonatomic) UIImageView *headerView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *messageView;


@end
