//
//  Photo.m
//  MockObjectSample
//
//  Created by Eric McConkie on 4/25/13.
//  Copyright (c) 2013 Eric McConkie. All rights reserved.
//

#import "Photo.h"

@implementation Photo
- (id)initWithDictionary:(NSDictionary*)d
{
    self = [super init];
    if (self) {
        self.ownerName = [d objectForKey:@"owner_name"];
        self.photoTitle= [d objectForKey:@"photo_title"];
        self.photoId = [d objectForKey:@"photo_id"];
        self.photoUrl = [d objectForKey:@"photo_file_url"];
        self.width = [[d objectForKey:@"width"] intValue];
        self.height = [[d objectForKey:@"height"] intValue];
    }
    return self;
}
@end
