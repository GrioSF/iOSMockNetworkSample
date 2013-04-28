//
//  ViewController.h
//  MockObjectSample
//
//  Created by Eric McConkie on 4/25/13.
//  Copyright (c) 2013 Eric McConkie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiUtility.h"

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ApiUtilityDelegate>
@property (nonatomic,strong)Photo *currentSelectedPhotoObject;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
