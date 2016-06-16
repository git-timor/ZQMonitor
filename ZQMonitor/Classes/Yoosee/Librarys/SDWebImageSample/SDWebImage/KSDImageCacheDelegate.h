//
//  SDImageCacheDelegate.h
//  Dailymotion
//
//  Created by Olivier Poitrey on 16/09/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSDImageCache;

@protocol KSDImageCacheDelegate <NSObject>

@optional
- (void)imageCache:(KSDImageCache *)imageCache didFindImage:(UIImage *)image forKey:(NSString *)key userInfo:(NSDictionary *)info;
- (void)imageCache:(KSDImageCache *)imageCache didNotFindImageForKey:(NSString *)key userInfo:(NSDictionary *)info;

@end
