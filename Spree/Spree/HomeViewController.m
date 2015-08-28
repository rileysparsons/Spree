//
//  HomeViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/30/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeHeaderView.h"
#import "HeaderSlideView.h"
#import "SpreeConfigManager.h"

@interface HomeViewController () <InfinitePagingViewDelegate>

@property HomeHeaderView *header;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.header = [[HomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    self.header.photoGallery.pageSize = CGSizeMake(self.tableView.frame.size.width, 200);
    [self setupHeaderSlides];
    [NSTimer scheduledTimerWithTimeInterval:4.0f target:self.header.photoGallery selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
    self.tableView.tableHeaderView = self.header;
}

-(void)setupHeaderSlides{
    
    PFQuery *userQuery = [PFUser query];
    [userQuery includeKey:@"campus"];
    [userQuery getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error){
        if (!error){
            NSMutableArray *bannerMetadata = [[[SpreeConfigManager sharedManager] campusBannerSlidesForNetworkCode:object[@"campus"][@"networkCode"]] mutableCopy];
            
            [bannerMetadata sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES]]];
            
            for (NSDictionary *bannerData in bannerMetadata){
                HeaderSlideView *view = [[HeaderSlideView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
                if (bannerData[@"title"]){
                    view.slideTitle.text = bannerData[@"title"];
                    view.slideTitle.textColor = [UIColor spreeOffWhite];
                    view.backgroundImage.backgroundColor = [UIColor spreeOffBlack];
                }
                
                if (bannerData[@"subtitle"]){
                    
                }
                
                [self.header.photoGallery addPageView:view];
            }
            
        } else {
            
        }
    }];

    
    
//    HeaderSlideView *view1 = [[HeaderSlideView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
//    HeaderSlideView *view2 = [[HeaderSlideView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
//    HeaderSlideView *view3 = [[HeaderSlideView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
//
//    
//    view1.backgroundImage.image = [UIImage imageNamed:@"missionsantaclara"];
//    
//    view1.backgroundImage.backgroundColor = [UIColor spreeOffBlack];
//    view2.backgroundImage.backgroundColor = [UIColor spreeOffBlack];
//    view3.backgroundImage.backgroundColor = [UIColor spreeOffBlack];
//    
//    view1.slideTitle.textColor = [UIColor spreeOffWhite];
//    view2.slideTitle.textColor = [UIColor spreeOffWhite];
//    view3.slideTitle.textColor = [UIColor spreeOffWhite];
//
//
//    [view1 setTitleWithString:@"Santa Clara University"];
//    [view2 setTitleWithString:@"Couches"];
//    [view3 setTitleWithString:@"Textbooks"];
//    
//    return [[NSArray alloc] initWithObjects:view1,view2,view3, nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self.header setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    [self sizeHeaderToFit];
}

- (void) sizeHeaderToFit {
    UIView *headerView = self.tableView.tableHeaderView;
    [headerView setNeedsLayout];
    [headerView layoutIfNeeded];
    CGFloat height = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    headerView.frame = ({
        CGRect headerFrame = headerView.frame;
        headerFrame.size.height = height;
        headerFrame;
    });
    
    self.tableView.tableHeaderView = headerView;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.header.photoGallery scrollToNextPage];
}



@end
