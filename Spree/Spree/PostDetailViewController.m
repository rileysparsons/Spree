//
//  PostDetailViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "PostDetailViewController.h"
#import "ContainerTableViewController.h"
#import "UIColor+SpreeColor.h"
#import "WSCoachMarksView.h"

#import "common.h"
#import "ChatView.h"
#import "recent.h"
#import "FindBuyerViewController.h"


@interface PostDetailViewController () {
    WSCoachMarksView *coachMarksView;
}

@property (nonatomic, strong) NSArray *pageImages;
@property (nonatomic, strong) NSMutableArray *pageViews;

- (void)loadVisiblePages;
- (void)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;

@end

@implementation PostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Page View Stuff
    if (self.detailPost.photoArray.count != 0){
        NSMutableArray *tempPhotoArray = [[NSMutableArray alloc] initWithCapacity:3];
        for (PFFile *imageFile in self.detailPost.photoArray){
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    [tempPhotoArray addObject:image];
                    // image can now be set on a UIImageView
                    self.pageImages =[NSArray arrayWithArray:tempPhotoArray];
                    [self setupGallery];
                }
            }];
        }
    } else {
        self.scrollView.hidden = YES;
        self.pageControl.hidden = YES;
    }
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden= NO;
    
    if (([[(PFUser *)_detailPost.user objectId] isEqualToString: [[PFUser currentUser] objectId]])){
//        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self actio:@selector(deleteButtonSelected)];
        self.navigationItem.rightBarButtonItem = nil;
        [self setupAdminBar];
        
    } else {
        self.adminBarView.hidden = YES;
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:self.detailPost.user.objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"%@", object);
            self.poster = (PFUser *)object;
            NSString *date = [NSDateFormatter localizedStringFromDate:[_detailPost createdAt] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
            _postDateUserLabel.text = [NSString stringWithFormat:@"Posted by %@ on %@", (_poster[@"name"]) ? _poster[@"name"] : _poster[@"username"], date];
            [self _loadData];
        }];
    }
    self.postScrollView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Bar title
    UILabel *tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    tlabel.textAlignment = NSTextAlignmentCenter;
    tlabel.text=self.self.detailPost.title;;
    tlabel.textColor=[UIColor whiteColor];
    tlabel.font = [UIFont fontWithName:@"Helvetica-Neue" size: 14.0];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    
    self.navigationItem.backBarButtonItem.title = @"Back";
    
    //Purchase Button
    self.purchaseButton.titleLabel.textColor = [UIColor whiteColor];
    self.purchaseButton.layer.cornerRadius = self.purchaseButton.frame.size.height/3;
    self.purchaseButton.layer.masksToBounds=YES;
    self.purchaseButton.layer.borderColor=[[UIColor whiteColor]CGColor];
    self.purchaseButton.layer.borderWidth= 1.0f;
    
    self.descriptionTextView.scrollEnabled = NO;
    
    // Add description
    self.descriptionTextView.text = _detailPost.userDescription;
    self.descriptionTextView.font = [UIFont fontWithName:@"Helvetica Neue Light Italic" size:16];
    CGSize sizeThatShouldFitTheContent = [self.descriptionTextView sizeThatFits:CGSizeMake(250, MAXFLOAT)];
    self.descriptionTextViewHeight.constant = sizeThatShouldFitTheContent.height;
    
    self.detailBarView.frame = CGRectMake(0, -45, self.view.frame.size.width, 45);
    [UIView animateWithDuration:0.50f animations:^{
        self.detailBarView.frame = CGRectMake(0, 0, self.view.frame.size.width, 45);
    } completion:^(BOOL finished) {
    
    }];
    
    // Type Conditions
    if (_detailPost.price == 0){
        [self.purchaseButton setTitle:@"Get" forState:UIControlStateNormal];
    } else {
        [self.purchaseButton setTitle:[NSString stringWithFormat:@"$%@", self.detailPost.price] forState:UIControlStateNormal];
        if ([_detailPost.type isEqualToString: @"Books"]){
            _bookForClassLabel.text = _detailPost[@"bookForClass"];
        }
        if ([_detailPost.type isEqualToString: @"Tickets"]){
            _eventDateForTicketLabel.text = _detailPost[@"eventDate"];
        }
        if ([_detailPost.type isEqualToString: @"Tasks"]){
            if (_detailPost[@"subtitle"]) {
                _taskLocationLabel.text = [NSString stringWithFormat:@"Location: %@", _detailPost[@"subtitle"]];
            }
        }
    }
    
    [self addCoachMarks];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popViewControllerAnimated)
                                                 name:@"UserRated"
                                               object:nil];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageImages.count, pagesScrollViewSize.height);
    

    [self loadVisiblePages];

    [self.postScrollView setContentOffset:CGPointMake(0, -5) animated:YES];
    
    // Show coach marks
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShown"];
    if (coachMarksShown == NO && self.detailPost.user != [PFUser currentUser]) {
        // Don't show again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WSCoachMarksShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        


        // Or show coach marks after a second delay
         [coachMarksView performSelector:@selector(start) withObject:nil afterDelay:2.5f];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [NSObject cancelPreviousPerformRequestsWithTarget:coachMarksView selector:@selector(start) object:nil];
}

-(void)addCoachMarks{
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{self.view.frame.size.width - (self.purchaseButton.frame.size.width + 11), 68},{self.purchaseButton.frame.size.width+6, 39}}],
                                @"caption": @"Get this item here!"
                                }
                            ];
    coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.tabBarController.view.bounds coachMarks:coachMarks];
    [self.tabBarController.view addSubview:coachMarksView];
    coachMarksView.maskColor = [UIColor colorWithWhite:1 alpha:.95];
    coachMarksView.lblCaption.textColor = [UIColor spreeBabyBlue];
    coachMarksView.lblCaption.font = [UIFont fontWithName:@"EuphemiaUCAS-Bold" size:24];
}

-(void)setupAdminBar{
    self.posterInfoView.hidden = YES;
    self.adminBarView.hidden = NO;
    self.posterInfoView.userInteractionEnabled = NO;
    
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.soldButton setTitle:@"Sold" forState:UIControlStateNormal];
    [self.repostButton setTitle:@"Repost" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor spreeLightYellow] forState:UIControlStateHighlighted];
     [self.deleteButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.25] forState:UIControlStateDisabled];
    self.deleteButton.layer.cornerRadius = self.purchaseButton.frame.size.height/3;
    self.deleteButton.layer.masksToBounds=YES;
    self.deleteButton.layer.borderColor=[[UIColor whiteColor]CGColor];
    self.deleteButton.layer.borderWidth= 1.0f;
    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];

    [self.soldButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.25] forState:UIControlStateDisabled];
    [self.soldButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.soldButton setTitleColor:[UIColor spreeLightYellow] forState:UIControlStateHighlighted];

    self.soldButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.soldButton.layer.cornerRadius = self.purchaseButton.frame.size.height/3;
    self.soldButton.layer.masksToBounds=YES;
    self.soldButton.layer.borderColor=[[UIColor whiteColor]CGColor];
    self.soldButton.layer.borderWidth= 1.0f;
    [self.repostButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.repostButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.25] forState:UIControlStateDisabled];
    [self.repostButton setTitleColor:[UIColor spreeLightYellow] forState:UIControlStateHighlighted];
    self.repostButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];

    self.repostButton.layer.cornerRadius = self.purchaseButton.frame.size.height/3;
    self.repostButton.layer.masksToBounds=YES;
    self.repostButton.layer.borderColor=[[UIColor whiteColor]CGColor];
    self.repostButton.layer.borderWidth= 1.0f;
    
    if (self.detailPost.sold == YES){
        self.soldButton.enabled = NO;
        self.soldButton.userInteractionEnabled = NO;
        self.repostButton.enabled = NO;
        self.repostButton.userInteractionEnabled = NO;
    } else {
        if (self.detailPost.expired == YES){
            self.soldButton.enabled = YES;
            self.repostButton.enabled = YES;
            self.repostButton.userInteractionEnabled = YES;
            self.soldButton.userInteractionEnabled = YES;
        } else {
            self.soldButton.enabled = YES;
            self.repostButton.enabled = NO;
            self.repostButton.userInteractionEnabled = NO;
            self.soldButton.userInteractionEnabled = YES;
        }
    }
}

- (void)_loadData {
    // Set the image in the header imageView
    self.profilePictureView.contentMode = UIViewContentModeScaleAspectFill;
    self.profilePictureView.layer.borderWidth = 2.0f;
    self.profilePictureView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.height/2;
    self.profilePictureView.clipsToBounds = YES;
    // ...
    
    // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", self.poster[@"fbId"]]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
    
    // Run network request asynchronously
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError == nil && data != nil) {
             // Set the image in the header imageView
             self.profilePictureView.contentMode = UIViewContentModeScaleAspectFill;
             self.profilePictureView.image = [UIImage imageWithData:data];
             self.profilePictureView.layer.borderWidth = 2.0f;
             self.profilePictureView.layer.borderColor = [UIColor whiteColor].CGColor;
             self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.height/2;
             self.profilePictureView.clipsToBounds = YES;
         } else {
             NSLog(@"%@", connectionError.description);
         }

     }];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView){
        // Load the pages that are now on screen
        [self loadVisiblePages];
    }
}


# pragma mark - Photo Gallery Scroll View
- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // 1
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        // 2
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        // 3
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:page]];
        newPageView.contentMode = UIViewContentModeScaleAspectFit;
        newPageView.frame = frame;
        [self.scrollView addSubview:newPageView];
        // 4
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    self.pageControl.currentPage = page;
    
    // Work out which pages you want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    
    // Load pages in our range
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    
    // Purge anything after the last page
    for (NSInteger i=lastPage+1; i<self.pageImages.count; i++) {
        [self purgePage:i];
    }
}

- (void)setupGallery {
    NSInteger pageCount = self.pageImages.count;
    NSLog(@"%lu", (unsigned long)self.pageImages.count);
    // 2
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = pageCount;
    
    // 3
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageImages.count, pagesScrollViewSize.height);
    [self loadVisiblePages];
}

- (IBAction)repostButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm repost" message:@"Are you sure you want to repost this item?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alertView.tag = 3;
    [alertView show];
}

- (IBAction)soldButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Item Sold" message:@"Are you sure you want to mark this item as sold? This permanently removes this post from active listings." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alertView.tag = 2;
    [alertView show];
}

- (IBAction)deleteButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete" message:@"Are you sure you want to delete this post?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alertView.tag = 1;
    [alertView show];
}

- (IBAction)purchaseButtonPressed:(id)sender {
    
    PFUser *user2 = self.poster;
    PFUser *user1 = [PFUser currentUser];

    NSString *groupId = StartPrivateChat(user1, user2);

    [self actionChat:groupId post:self.detailPost];
}


# pragma mark - UIAlertView methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 1:
            if (buttonIndex == 1){
                [self.detailPost deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTable" object:nil];
                    }
                }];
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        case 2:
            if (buttonIndex == 1){
                [self.detailPost setSold:YES];
                [self.detailPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTable" object:self];
                        FindBuyerViewController *findBuyerView = [self.storyboard instantiateViewControllerWithIdentifier:@"findbuyer"];
                        findBuyerView.post = self.detailPost;

                        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:findBuyerView];

                        [self presentViewController:navigationController animated:YES completion:NULL];
                    }
                }];
            }
            break;
        case 3:
            if (buttonIndex == 1){
                [self.detailPost setExpired:NO];
                [self.detailPost setSold:NO];
                [self.detailPost saveInBackground];
                [self setupAdminBar];
            }
            break;
        default:
            break;
    }
}

- (void)popViewControllerAnimated {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionChat:(NSString *)groupId post:(PFObject *)post_
{
    ChatView *chatView = [[ChatView alloc] initWith:groupId post:post_ title:_poster[@"username"]];

    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
    // Unhide the tabbar when we go back
    self.hidesBottomBarWhenPushed = NO;
}

@end