//
//  MockObjectSampleTests.m
//  MockObjectSampleTests
//
//  Created by Eric McConkie on 4/25/13.
//  Copyright (c) 2013 Eric McConkie. All rights reserved.
//

#import "MockObjectSampleTests.h"
#import <OCMock/OCMock.h>
#import "ApiUtility.h"
#import "Photo.h"
#import "ViewController.h"

@interface MockObjectSampleTests()

@end

@implementation MockObjectSampleTests

- (void)setUp
{
    [super setUp];
    
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

// some stubbed data to return (actuall json from api)
-(NSArray*)stubResults
{
    NSString *file = [[NSBundle bundleForClass:[self class]] pathForResource:@"panoresults" ofType:@"json"];
    NSData *dta = [NSData dataWithContentsOfFile:file];
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:dta options:NSJSONReadingMutableLeaves error:&error];
    NSArray *photos = [ApiUtility objectsForResults:json];
    return photos;
}


//test and STUB data results
// shows how to mock and stub the "response" block on api query 
- (void)testMockApiQuerySuccess
{
    //1
    id mock = [OCMockObject mockForClass:[ApiUtility class]];

    //2
    [[[mock stub]andDo:^(NSInvocation *invocation) {
        //our stubbed results
        NSArray *photos = [self stubResults];
        
        //the block we will invoke
        void (^responseHandler)(NSArray *photoArray)= nil;
        
        //0 and 1 are reserved for invocation object, ....therefor 2 would be jsonForLocation, 3 is response (block)
        [invocation getArgument:&responseHandler atIndex:3];
        
        //invoke the block
        responseHandler(photos);
    }]  jsonForLocation:[OCMArg any]
     response:[OCMArg any]error:[OCMArg any]];
       
    //3
    [mock jsonForLocation:[OCMArg any] response:^(NSArray *photoObjects) {
        //NSLog(@"calling response block from test %@",photoObjects);
        STAssertTrue([photoObjects count]==20, @"has results");
    } error:^(NSError *error) {
        //we should not see this in our test
        STAssertTrue(NO, @"should not have an error");
    }];
}

- (void)testMockApiQueryFail
{
    //1
    id mock = [OCMockObject mockForClass:[ApiUtility class]];
    
    //2
    [[[mock stub]andDo:^(NSInvocation *invocation) {
        //our stubbed results
        NSError *error = [NSError errorWithDomain:@"XXXXX" code:1 userInfo:nil];
        
        //the block we will invoke
        void (^errorHandler)(NSError *error)= nil;

        [invocation getArgument:&errorHandler atIndex:4];
        
        //invoke the block
        errorHandler(error);
    }]  jsonForLocation:[OCMArg any]
     response:[OCMArg any]error:[OCMArg any]];
    
    //3
    [mock jsonForLocation:[OCMArg any] response:^(NSArray *photoObjects) {
        //we should not see this in our test
        STAssertTrue(NO, @"should not see this");
    } error:^(NSError *error) {
        STAssertTrue(error != nil, @"should not have an error");
        STAssertTrue(error.code == 1, @"should not have an error");
    }];
}



// test that our apiutility protocol works on success of fetching an image
// mock the actual network call, and stub the results
-(void)testImageDownloadSuccess
{
    //**********************************************************
    //1.set up the mock players
    //**********************************************************
    __block ApiUtility *util = [[ApiUtility alloc] init]; 
    ViewController *vc = [[ViewController alloc ] init];    
    //set the delegate and do the action
    [util setDelegate:vc];
    
    //**********************************************************
    //2.mock a sceneraio and stub some fake data
    //**********************************************************    
    id mockDelegate = [OCMockObject partialMockForObject:vc];
    [[[mockDelegate expect] andDo:^(NSInvocation *invocation) {
        
        //3.
        //mocks we will pass back
        id mockImage = [OCMockObject mockForClass:[UIImage class]];
        id mockPhoto = [OCMockObject mockForClass:[Photo class]];
        // we need to set these properties (to anything),
        // because ViewController will try to use them on success of image download
        [[[mockPhoto stub]andReturn:[OCMArg any]] photoId];
        [[[mockPhoto stub]andReturn:[OCMArg any]] photoTitle];
        [[[mockPhoto stub]andReturn:[OCMArg any]] ownerName];
        
        [invocation setTarget:vc];
        [invocation setSelector:@selector(apiUtility:didCompleteDownloadingImage:forPhoto:)];
        
        //again 0 and 1 are reserved for the invocation object , so...
        [invocation setArgument:&util atIndex:2];//apitutil
        [invocation setArgument:&mockImage atIndex:3];//fake returned image
        [invocation setArgument:&mockPhoto atIndex:4];//the mock photo
        [invocation invoke];//actually involke apiUtility:didCompleteDownloadingImage:forPhoto:
    }]
     apiUtility:[OCMArg any] didCompleteDownloadingImage:[OCMArg any] forPhoto:[OCMArg any]];
    
    //4. the mock object that will mock a download/ApiUtility
    id mockUtil = [OCMockObject partialMockForObject:util];
    [[[mockUtil stub]
      andCall:@selector(apiUtility:didCompleteDownloadingImage:forPhoto:) onObject:mockDelegate] //we must call the protocol, as the real method would fail without network 
     downloadLargeImage:[OCMArg any]];
    
    //5. do the download
    [mockUtil downloadLargeImage:[OCMArg any]];
    
    //6. make sure the delegate got the call
    [mockDelegate verify];//make sure out delegate method is actually called
    
    
    //assert!
    STAssertTrue(vc.currentSelectedPhotoObject!=nil, @"should have mock photo");
}


//test that our apiutility protocol works on success of image upload
-(void)testImageUploadSuccess
{
    //mock a class that implements the protocol method
    id aMock = [OCMockObject mockForProtocol:@protocol(ApiUtilityDelegate)];
    [[aMock expect]apiUtilityDidCompleteImageUpload:[OCMArg any]];
    
    ApiUtility *aUtil = [[ApiUtility alloc] init];
    [aUtil setDelegate:aMock];
    [aUtil uploadFancyImages:[OCMArg any]];//we don't really have to upload an image here
    
    [aMock verify];
}



@end
