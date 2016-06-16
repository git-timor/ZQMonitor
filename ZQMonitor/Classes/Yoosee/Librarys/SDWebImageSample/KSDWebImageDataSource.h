//
//  SDWebImageDataSource.h
//  Sample
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"


@interface KSDWebImageDataSource : NSObject <KTPhotoBrowserDataSource>
@property (nonatomic, strong) NSMutableArray *screenshotPaths;
@end
