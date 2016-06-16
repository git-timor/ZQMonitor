//
//  KTPhotoView+SDWebImage.h
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTPhotoView.h"
#import "KSDWebImageManagerDelegate.h"

@interface KTPhotoView (KSDWebImage) <KSDWebImageManagerDelegate>

- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end