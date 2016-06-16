/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "KSDWebImageDownloaderDelegate.h"

extern NSString *const KSDWebImageDownloadStartNotification;
extern NSString *const KSDWebImageDownloadStopNotification;

@interface KSDWebImageDownloader : NSObject
{
    @private
    NSURL *url;
    id<KSDWebImageDownloaderDelegate> delegate;
    NSURLConnection *connection;
    NSMutableData *imageData;
	id userInfo;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) id<KSDWebImageDownloaderDelegate> delegate;
@property (nonatomic, retain) NSMutableData *imageData;
@property (nonatomic, retain) id userInfo;

+ (id)downloaderWithURL:(NSURL *)url delegate:(id<KSDWebImageDownloaderDelegate>)delegate userInfo:(id)userInfo;
+ (id)downloaderWithURL:(NSURL *)url delegate:(id<KSDWebImageDownloaderDelegate>)delegate;
- (void)start;
- (void)cancel;

// This method is now no-op and is deprecated
+ (void)setMaxConcurrentDownloads:(NSUInteger)max __attribute__((deprecated));

@end
