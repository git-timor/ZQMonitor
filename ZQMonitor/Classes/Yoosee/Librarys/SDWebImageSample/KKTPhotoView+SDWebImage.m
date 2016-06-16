//
//  KTPhotoView+SDWebImage.m
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KKTPhotoView+SDWebImage.h"
#import "KSDWebImageManager.h"

@implementation KTPhotoView (KSDWebImage)

- (void)setImageWithURL:(NSURL *)url {
   [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
   KSDWebImageManager *manager = [KSDWebImageManager sharedManager];
   
   // Remove in progress downloader from queue
   [manager cancelForDelegate:self];
   
   UIImage *cachedImage = nil;
   if (url) {
     cachedImage = [manager imageWithURL:url];
   }
   
   if (cachedImage) {
      [self setImage:cachedImage];
   }
   else {
      if (placeholder) {
         [self setImage:placeholder];
      }
      
      if (url) {
        [manager downloadWithURL:url delegate:self];
      }
   }
}

- (void)webImageManager:(KSDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
   [self setImage:image];
}

@end