//
//  ApiUtility.m
//  MockObjectSample
//
//  Created by Eric McConkie on 4/25/13.
//  Copyright (c) 2013 Eric McConkie. All rights reserved.
//

#import "ApiUtility.h"
#import "Photo.h"

@implementation ApiUtility


+(NSArray*)objectsForResults:(id )json
{
    NSMutableArray *mAr = [NSMutableArray array];
    for (NSDictionary *d in [json objectForKey:@"photos"]) {
        Photo *p = [[Photo alloc] initWithDictionary:d];
        [mAr addObject:p];
    }
    return mAr;
}

/*
 // it is intended that this method be wrapped in a secondary thread (GCD)
 */
-(void)jsonForLocation:(NSDictionary*)params response:(void(^)(NSArray *photoObjects))block error:(void(^)(NSError *error))error
{
    [self setIsFetchingData:YES];
    NSString *urlWIthFormat = @"http://www.panoramio.com/map/get_panoramas.php?set=public&from=0&to=20&minx=%f&miny=%f&maxx=%f&maxy=%f&size=square&mapfilter=true";
    NSString *urlPath = [NSString stringWithFormat:urlWIthFormat,
                         [[params objectForKey:@"minx"] doubleValue],
                         [[params objectForKey:@"miny"] doubleValue],
                         [[params objectForKey:@"maxx"] doubleValue],
                         [[params objectForKey:@"maxy"] doubleValue]
                         ];
    
    NSData *dta = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlPath]];
    
    NSError *anError = nil;
    if (anError == nil) {
        id json = [NSJSONSerialization JSONObjectWithData:dta options:NSJSONReadingMutableLeaves error:&anError];
        NSArray *mAr = [ApiUtility objectsForResults:json];
        block(mAr);
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationApiDidGetResults object:mAr];
    }else
    {
        error(anError);
    }
    [self setIsFetchingData:NO];
}

-(void)downloadLargeImage:(Photo*)photo
{
    NSString *baseurl = @"http://mw2.google.com/mw-panoramio/photos/medium/%@.jpg";
    NSString *path  = [NSString stringWithFormat:baseurl,photo.photoId];
    dispatch_queue_t backgroundQueue;
    backgroundQueue = dispatch_queue_create("fetchlargeimage", NULL);
    
    dispatch_async(backgroundQueue, ^(void) {
        NSData *dta = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
        UIImage *image = [UIImage imageWithData:dta];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if ([self.delegate respondsToSelector:@selector(apiUtility:didCompleteDownloadingImage:forPhoto:)]) {
                [self.delegate apiUtility:self didCompleteDownloadingImage:image forPhoto:photo];
            }
        });
    });
    

}

-(void)uploadFancyImages:(UIImage*)image
{
    //...do something fancy uploading 
    
    //..if successful, tell the delegate
    if ([self.delegate respondsToSelector:@selector(apiUtilityDidCompleteImageUpload:)]) {
        [self.delegate apiUtilityDidCompleteImageUpload:self];
    }
}

@end
