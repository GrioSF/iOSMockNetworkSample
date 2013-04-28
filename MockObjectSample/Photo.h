//
//  Photo.h
//  MockObjectSample
//
//  Created by Eric McConkie on 4/25/13.
//  Copyright (c) 2013 Eric McConkie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject
@property (nonatomic,copy)NSString *ownerName;
@property (nonatomic,copy)NSString *photoUrl;
@property (nonatomic,copy)NSString *photoTitle;
@property (nonatomic, copy) NSString *photoId;
@property (nonatomic) int width;
@property (nonatomic) int height;

- (id)initWithDictionary:(NSDictionary*)d;
@end
