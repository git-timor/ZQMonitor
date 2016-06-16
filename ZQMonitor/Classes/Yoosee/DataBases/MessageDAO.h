//
//  MessageDAO.h
//  Yoosee
//
//  Created by guojunyi on 14-5-29.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2PMessage.h"
#import "sqlite3.h"
#define DB_NAME @"Yoosee.sqlite"
@interface MessageDAO : NSObject
@property (nonatomic) sqlite3 *db;


-(BOOL)insert:(P2PMessage*)recent;
-(NSMutableArray*)findAllWithId:(NSString*)contactId;
-(BOOL)delete:(P2PMessage*)recent;
-(BOOL)clearWithId:(NSString*)contactId;

-(BOOL)updateMessageStateWithFlag:(NSInteger)flag state:(NSInteger)state;
-(BOOL)update:(P2PMessage*)message;
@end
