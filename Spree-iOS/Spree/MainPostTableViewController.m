//
//  HomeViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/30/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "MainPostTableViewController.h"

#import "HomeHeaderView.h"
#import "HeaderSlideView.h"
#import "SpreeConfigManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

static const CGFloat kHeaderSlideShowHeight = 125.0f;

@interface MainPostTableViewController () <InfinitePagingViewDelegate, UIGestureRecognizerDelegate>

@property HomeHeaderView *header;
@property NSMutableArray *slides; // For reference when touched
@property NSMutableArray *metadata;
@property NSTimeInterval lastTouchTime;
@property NSInteger pagingViewIndex;

@end

@implementation MainPostTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)setupHeaderSlides{
    
    self.header = [[HomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.postsTableView.frame.size.width, kHeaderSlideShowHeight)];
    self.header.photoGallery.pageSize = CGSizeMake(self.postsTableView.frame.size.width, kHeaderSlideShowHeight);
    self.header.headerGestureRecognizer.delegate = self;
    
    NSLog(@"frame size: %f", self.postsTableView.frame.size.width);
    
    HeaderSlideView *slide1 = [[HeaderSlideView alloc] initWithFrame:CGRectMake(0, 0, self.postsTableView.frame.size.width, kHeaderSlideShowHeight)];
    [slide1 setupForMetadata:@{@"title": @"WELCOME TO SPREE", @"subtitle": @"A Sustainable, Student-to-Student Marketplace", @"backgroundColor":@"#094b96", @"titleColor":@"#f6f7f7", @"subtitleColor":@"#f6f7f7"}];
    
    [self.header.photoGallery addPageView: slide1];
    HeaderSlideView *slide2 = [[HeaderSlideView alloc] initWithFrame:CGRectMake(0, 0, self.postsTableView.frame.size.width, kHeaderSlideShowHeight)];
    [slide2 setupForMetadata:@{@"title": @"BOOKS TO RIDES", @"subtitle": @"Students can sell both goods and services on Spree", @"backgroundColor":@"#2b2f33", @"titleColor":@"#f6f7f7", @"subtitleColor":@"#f6f7f7"}];
    [self.header.photoGallery addPageView: slide2];
    HeaderSlideView *slide3 = [[HeaderSlideView alloc] initWithFrame:CGRectMake(0, 0, self.postsTableView.frame.size.width, kHeaderSlideShowHeight)];
    [slide3 setupForMetadata:@{@"title": @"SUSTAINABLILITY AND SAVINGS", @"subtitle": @"Spree fosters a sustainable community on any campus nationwide", @"backgroundColor":@"#B2B707", @"titleColor":@"#2b2f33", @"subtitleColor":@"#2b2f33"}];
    [self.header.photoGallery addPageView: slide3];
    
    self.slides = [[NSMutableArray alloc] initWithArray:@[slide1, slide2, slide3]];
    self.metadata = [[NSMutableArray alloc] init];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery includeKey:@"campus"];
    [userQuery getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error){
        if (!error){
            
            NSMutableArray *bannerMetadata = [[[SpreeConfigManager sharedManager] campusBannerSlidesForNetworkCode:object[@"campus"][@"networkCode"]] mutableCopy];
            
            [bannerMetadata sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES]]];
            
            for (HeaderSlideView *slideView in self.slides){
                
                 BOOL exists = [self.slides indexOfObject:slideView] < [bannerMetadata count] ? YES : NO;
                if (exists){
                    
                    NSDictionary *bannerData = [bannerMetadata objectAtIndex:[self.slides indexOfObject:slideView]];
                    [slideView setupForMetadata:bannerData];
                    
                    
                    [self.metadata insertObject:bannerData atIndex:[self.slides indexOfObject:slideView]];
                }
            }
            
            self.header.photoGallery.delegate = self;
            
            [NSTimer scheduledTimerWithTimeInterval:4.0f target:self.header.photoGallery selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
            self.postsTableView.tableHeaderView = self.header;
        } else {
            
        }
    }];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSLog(@"frame width: %f", self.postsTableView.frame.size.width);
    NSLog(@"window width: %f", self.view.frame.size.width);
    [self.header setFrame:CGRectMake(0, 0, self.postsTableView.frame.size.width, kHeaderSlideShowHeight)];
    [self sizeHeaderToFit];
    [self setupHeaderSlides];
}

- (void) sizeHeaderToFit {
    UIView *headerView = self.postsTableView.tableHeaderView;
    [headerView setNeedsLayout];
    [headerView layoutIfNeeded];
    CGFloat height = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGFloat width = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].width;
    headerView.frame = ({
        CGRect headerFrame = headerView.frame;
        headerFrame.size.height = height;
        headerFrame.size.width = width;
        headerFrame;
    });
    
    self.postsTableView.tableHeaderView = headerView;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.header.photoGallery scrollToNextPage];
}



-(void)userTouchedSlide{
    BOOL exists = self.pagingViewIndex < [self.metadata count] ? YES : NO;
    if (exists){
        NSDictionary *slideMetadata = [self.metadata objectAtIndex:self.pagingViewIndex];
        if ([[slideMetadata objectForKey:BANNER_LINKTYPE]
            isEqualToString:@"query"]){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            if (slideMetadata[@"parameters"]){
                PostTableViewController *postTableViewController = [[PostTableViewController alloc] init];
                postTableViewController.postQueryParameters = slideMetadata[@"parameters"];
                [self.navigationController pushViewController:postTableViewController animated:YES];
            }
        } else if ([[slideMetadata objectForKey:BANNER_LINKTYPE] isEqualToString:@"post"]){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            self.postDetailTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostDetail"];
            [slideMetadata[@"post"] fetchIfNeededInBackgroundWithBlock:^(PFObject* object, NSError *error){
                [self.postDetailTableViewController initWithPost:(SpreePost *)object];
                [self.navigationController pushViewController:self.postDetailTableViewController animated:YES];
            }];
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)pagingView:(InfinitePagingView *)pagingView didEndDecelerating:(UIScrollView *)scrollView atPageIndex:(NSInteger)pageIndex{
    
    pageIndex++;
    if (pageIndex > 2){
        pageIndex = 0;
    }

    self.pagingViewIndex = pageIndex;
    
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    [self userTouchedSlide];
    return YES;
}

@end
