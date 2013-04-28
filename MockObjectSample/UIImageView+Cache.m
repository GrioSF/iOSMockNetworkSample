//
//  UIImageView+Cache.m
//  Swoon
//
//  Created by Eric McConkie on 4/11/13.
//  Copyright (c) 2013 Douglas Kadlecek. All rights reserved.
//

#import "UIImageView+Cache.h"

@implementation UIImageView (Cache)


-(void)setRemoteImage:(NSString*)remoteImageUrl finished:(void (^)(UIImage *image))finished
{
    dispatch_queue_t backgroundQueue;
    backgroundQueue = dispatch_queue_create("fetchImageURL", NULL);
    dispatch_async(backgroundQueue, ^(void) {
        NSString *cacheProfileImagePathURL = [remoteImageUrl stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        UIImage *profileImage = nil;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *cachePath = NSTemporaryDirectory();
        cachePath = [cachePath stringByAppendingPathComponent:cacheProfileImagePathURL];
        if ([fm fileExistsAtPath:cachePath]) {
            profileImage = [UIImage imageWithContentsOfFile:cachePath];
        }else
        {
            NSData *dta = [NSData dataWithContentsOfURL:[NSURL URLWithString:remoteImageUrl]];
            profileImage = [UIImage imageWithData:dta];
            [fm createFileAtPath:cachePath contents:dta attributes:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            finished(profileImage);
        });
        
    });
#if __has_feature(objc_arc)
    
#elif 
    dispatch_release(backgroundQueue);
#endif
}

@end
