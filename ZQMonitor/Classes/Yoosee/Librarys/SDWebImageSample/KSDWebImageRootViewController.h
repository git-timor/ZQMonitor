//
//  SDWebImageRootViewController.h
//  Sample
//
//  Created by Kirby Turner on 3/18/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTThumbsViewController.h"

@class KSDWebImageDataSource;
#define ALERT_TAG_CLEAR 0

@interface KSDWebImageRootViewController : KTThumbsViewController{
@private
   KSDWebImageDataSource *images_;
   UIActivityIndicatorView *activityIndicatorView_;
   UIWindow *window_;
}

@end
