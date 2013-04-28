//
//  ViewController.m
//  MockObjectSample
//
//  Created by Eric McConkie on 4/25/13.
//  Copyright (c) 2013 Eric McConkie. All rights reserved.
//

#import "ViewController.h"
#import "ImageDisplayViewController.h"
#import "UIImageView+Cache.h"
#import "Photo.h"
@interface ViewController ()

@property (nonatomic,strong)ApiUtility *apiUtil;
@property (nonatomic,strong)NSArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.apiUtil = [[ApiUtility alloc] init];
    [self.apiUtil setDelegate:self];
    
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                       @-122.240753,@"minx",
                       @37.893279,@"miny",
                       @-122.340753,@"maxx",
                       @39.893279,@"maxy"
                       , nil];
    [self.apiUtil jsonForLocation:d
                         response:^(NSArray *photoObjects) {
                             [self setDataSource:photoObjects];
                             [self.tableView reloadData];
                         } error:^(NSError *error) {
                             NSLog(@"OH OH - FAIL\r\n---> %@",error);
                         }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark table delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

-(UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"defaultcellId";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    Photo *p = [self.dataSource objectAtIndex:indexPath.row];
    [cell.detailTextLabel setText:p.ownerName];
    [cell.textLabel setText:p.photoTitle];
    
    //placeholder
    if (cell.imageView.image == nil) {
        UIImage *logo = [UIImage imageNamed:@"logo.jpeg"];
        [cell.imageView setImage:logo];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    //get and cache image
    __block UITableViewCell *bCell = cell;
    [cell.imageView setRemoteImage:p.photoUrl finished:^(UIImage *image) {
        [bCell.imageView setImage:image];
        
    }];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Photo *selectedPhotoObject = [self.dataSource objectAtIndex:indexPath.row];
    
    [self.apiUtil downloadLargeImage:selectedPhotoObject];
    
    
}


#pragma mark -
#pragma mark api util delegate
-(void)apiUtility:(id)utility didCompleteDownloadingImage:(UIImage *)image forPhoto:(Photo *)photo
{
    
    self.currentSelectedPhotoObject = photo;
    ImageDisplayViewController *vc = [[ImageDisplayViewController alloc] initWithNibName:@"ImageDisplayViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc.imageView setImage:image];
    [vc.txtView setText:[NSString stringWithFormat:@"%@\r\n%@",
                         photo.photoTitle,
                         photo.ownerName]];
    
    
    
}
@end
