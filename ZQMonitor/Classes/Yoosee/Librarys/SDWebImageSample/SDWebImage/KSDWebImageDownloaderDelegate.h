/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <UIKit/UIKit.h>

@class KSDWebImageDownloader;

@protocol KSDWebImageDownloaderDelegate <NSObject>

@optional

- (void)imageDownloaderDidFinish:(KSDWebImageDownloader *)downloader;
- (void)imageDownloader:(KSDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image;
- (void)imageDownloader:(KSDWebImageDownloader *)downloader didFailWithError:(NSError *)error;

@end
