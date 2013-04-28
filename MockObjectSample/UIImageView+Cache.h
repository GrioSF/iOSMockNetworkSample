//
//  UIImageView+Cache.h
//  Swoon
//
//  Created by Eric McConkie on 4/11/13.
//  Copyright (c) 2013 Douglas Kadlecek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Cache)
-(void)setRemoteImage:(NSString*)remoteImageUrl finished:(void (^)(UIImage *image))finished;
@end
