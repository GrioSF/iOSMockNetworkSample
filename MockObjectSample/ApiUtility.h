//
//  ApiUtility.h
//  MockObjectSample
//
//  Created by Eric McConkie on 4/25/13.
//  Copyright (c) 2013 Eric McConkie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

#define kNotificationApiDidGetResults   @"kNotificationApiDidGetResults"

@protocol ApiUtilityDelegate <NSObject>

-(void)apiUtility:(id)utility didCompleteDownloadingImage:(UIImage*)image forPhoto:(Photo*)photo;

@optional
-(void)apiUtilityDidCompleteImageUpload:(id)apiUtil;

@end

@interface ApiUtility : NSObject

@property (nonatomic,assign) id<ApiUtilityDelegate> delegate;
@property (nonatomic) BOOL isFetchingData;


-(void)jsonForLocation:(NSDictionary*)params response:(void(^)(NSArray *photoObjects))block error:(void(^)(NSError *error))error;
-(void)downloadLargeImage:(Photo*)photo;
-(void)uploadFancyImages:(UIImage*)image;

+(NSArray*)objectsForResults:(id )json;

@end
