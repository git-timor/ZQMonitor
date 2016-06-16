/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <UIKit/UIKit.h>
#import "KSDWebImageDownloaderDelegate.h"
#import "KSDWebImageManagerDelegate.h"
#import "KSDImageCacheDelegate.h"

@interface KSDWebImageManager : NSObject <KSDWebImageDownloaderDelegate, KSDImageCacheDelegate>
{
    NSMutableArray *delegates;
    NSMutableArray *downloaders;
    NSMutableDictionary *downloaderForURL;
    NSMutableArray *failedURLs;
}

+ (id)sharedManager;
- (UIImage *)imageWithURL:(NSURL *)url;
- (void)downloadWithURL:(NSURL *)url delegate:(id<KSDWebImageManagerDelegate>)delegate;
- (void)cancelForDelegate:(id<KSDWebImageManagerDelegate>)delegate;

@end
