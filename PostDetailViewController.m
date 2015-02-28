//
//  PostDetailViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "PostDetailViewController.h"
#import "ContainerTableViewController.h"
#import "AppDelegate.h"



@interface PostDetailViewController ()

@end

@implementation PostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden= NO;
    self.navigationItem.title= @"Post";
    
    if (([[(PFUser *)_detailPost.user objectId] isEqualToString: [[PFUser currentUser] objectId]])){
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteButtonSelected)];
        self.navigationItem.rightBarButtonItem = editButton;
        
    }
    self.postScrollView.delegate = self;
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (_detailPost.imageFile){
        self.postImageView.contentMode = UIViewContentModeScaleAspectFill;
        PFFile *postImageFile = _detailPost.imageFile;
        [postImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            self.postImage = image;
            self.postImageView.image = image;
        }];
    } else {
        self.postImageView.contentMode = UIViewContentModeScaleAspectFit;
        if ([_detailPost.type isEqualToString:@"Tickets"]){
            _postImageView.image = [UIImage imageNamed:@"ticketGraphic"];
        } else if ([_detailPost.type isEqualToString:@"Books"]){
            _postImageView.image = [UIImage imageNamed:@"booksGraphic"];
        } else if ([_detailPost.type isEqualToString:@"Electronics"]){
            _postImageView.image = [UIImage imageNamed:@"electronicsGraphic"];
        } else if ([_detailPost.type isEqualToString:@"Free"]){
            _postImageView.image = [UIImage imageNamed:@"freeGraphic"];
        }
    }
    self.postTitleLabel.text = _detailPost.title;
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocation *currentLocation=appDelegate.locationManager.location;
    PFGeoPoint *postGeopoint = _detailPost.location;
    CLLocation *postLocation = [[CLLocation alloc] initWithLatitude:postGeopoint.latitude longitude:postGeopoint.longitude];
    CLLocationDistance distance = [currentLocation distanceFromLocation:postLocation];
    float distanceInMiles = distance*0.000621371;
    if (distanceInMiles > 1){
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1f miles away", distanceInMiles];
    } else {
        float number= distanceInMiles*5280;
        NSNumberFormatter *format = [[NSNumberFormatter alloc]init];
        [format setNumberStyle:NSNumberFormatterDecimalStyle];
        [format setRoundingMode:NSNumberFormatterRoundHalfUp];
        [format setMaximumFractionDigits:0];
        NSString *temp = [format stringFromNumber:[NSNumber numberWithFloat:number]];

        self.distanceLabel.text = [NSString stringWithFormat:@"%@ feet away", temp];
    }
    CALayer *shade = [CALayer layer];
    shade.frame = CGRectMake(0, -70, _postImageView.bounds.size.width, _postImageView.bounds.size.height+110);
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = shade.frame;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor],
                                              (id)[[UIColor clearColor] CGColor], nil];
    [shade insertSublayer:gradientLayer atIndex:0];
    
    [_postImageView.layer insertSublayer:shade atIndex:0];
    
    
    NSString *date = [NSDateFormatter localizedStringFromDate:[_detailPost createdAt] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    _postDateLabel.text = date;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.postScrollView setContentOffset:CGPointMake(0, -5) animated:YES];
}

-(void)deleteButtonSelected {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete" message:@"Are you sure you want to delete your post?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat y = -scrollView.contentOffset.y;
    if (y > 0) {
        self.postImageView.frame = CGRectMake(0, scrollView.contentOffset.y, self.postImage.size.width+y, self.postImage.size.height+y);
        self.postImageView.center = CGPointMake(self.view.center.x, self.postImageView.center.y);
    }
    
}

#pragma mark - Container View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedContainer"])
    {
        ContainerTableViewController *container = [[ContainerTableViewController alloc] init];
        container = segue.destinationViewController;
        [segue.destinationViewController setDetailPost:_detailPost];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        PFObject *postToDelete = [PFObject objectWithoutDataWithClassName:@"Post" objectId:[_detailPost objectId]];
        NSLog(@"%@", postToDelete);
        [postToDelete deleteEventually];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
