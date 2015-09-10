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

static const CGFloat kHeaderSlideShowHeight = 125.0f;

@interface HomeViewController () <InfinitePagingViewDelegate, UIGestureRecognizerDelegate>

@property HomeHeaderView *header;
@property NSMutableArray *slides; // For reference when touched
@property NSMutableArray *metadata;
@property NSTimeInterval lastTouchTime;
@property NSInteger pagingViewIndex;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupHeaderSlides];
}

-(void)setupHeaderSlides{
    
    self.header = [[HomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kHeaderSlideShowHeight)];
    self.header.photoGallery.pageSize = CGSizeMake(self.tableView.frame.size.width, kHeaderSlideShowHeight);
    self.header.headerGestureRecognizer.delegate = self;
    
    HeaderSlideView *slide1 = [[HeaderSlideView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kHeaderSlideShowHeight)];
    [self.header.photoGallery addPageView: slide1];
    HeaderSlideView *slide2 = [[HeaderSlideView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kHeaderSlideShowHeight)];
    [self.header.photoGallery addPageView: slide2];
    HeaderSlideView *slide3 = [[HeaderSlideView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kHeaderSlideShowHeight)];
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
                    
                    [self.metadata addObject:bannerData];
                }
            }
            
            self.header.photoGallery.delegate = self;
            NSLog(@"%@", self.header.photoGallery.delegate);
            
            [NSTimer scheduledTimerWithTimeInterval:4.0f target:self.header.photoGallery selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
            self.tableView.tableHeaderView = self.header;
        } else {
            
        }
    }];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self.header setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kHeaderSlideShowHeight)];
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



-(void)userTouchedSlide{

    BOOL exists = self.pagingViewIndex < [self.metadata count] ? YES : NO;
    if (exists){
        NSDictionary *slideMetadata = [self.metadata objectAtIndex:self.pagingViewIndex];
        if ([[slideMetadata objectForKey:BANNER_LINKTYPE] isEqualToString:@"query"]){
            if (slideMetadata[@"parameters"]){
                PostTableViewController *postTableViewController = [[PostTableViewController alloc] initWithStyle:UITableViewStylePlain];
                postTableViewController.postQueryParameters = slideMetadata[@"parameters"];
                [self.navigationController pushViewController:postTableViewController animated:YES];
            } else if ([[slideMetadata objectForKey:BANNER_LINKTYPE] isEqualToString:@"post"]){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                self.postDetailTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostDetail"];
                NSLog(@"%@", self.storyboard);
                [self.postDetailTableViewController initWithPost:slideMetadata[@"post"]];
                [self.navigationController pushViewController:self.postDetailTableViewController animated:YES];
            } else if ([[slideMetadata objectForKey:BANNER_LINKTYPE] isEqualToString:@"competition"]){
//                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//                self.postDetailTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostDetail"];
//                NSLog(@"%@", self.storyboard);
                [self.postDetailTableViewController initWithPost:slideMetadata[@"post"]];
                [self.navigationController pushViewController:self.postDetailTableViewController animated:YES];
            }
        }
    }
    
    NSLog(@"YES");
}

-(void)pagingView:(InfinitePagingView *)pagingView didEndDecelerating:(UIScrollView *)scrollView atPageIndex:(NSInteger)pageIndex{
    self.pagingViewIndex = pageIndex;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    [self userTouchedSlide];
    return YES;
}

@end
