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
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "UIColor+SpreeColor.h"
#import <WSCoachMarksView/WSCoachMarksView.h>



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
            _postDateUserLabel.text = [NSString stringWithFormat:@"Posted by %@ on %@", _poster[@"name"], date];
            [self _loadData];
        }];
    }
    self.postScrollView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Bar title
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
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
    CGSize sizeThatShouldFitTheContent = [self.descriptionTextView sizeThatFits:CGSizeMake(self.descriptionTextView.frame.size.width, MAXFLOAT)];
    self.descriptionTextViewHeight.constant = sizeThatShouldFitTheContent.height;
    
    self.detailBarView.frame = CGRectMake(0, -45, self.view.frame.size.width, 45);
    [UIView animateWithDuration:0.50f animations:^{
        self.detailBarView.frame = CGRectMake(0, 0, self.view.frame.size.width, 45);
    } completion:^(BOOL finished) {
    
    }];
    

    // Type Conditions
    if ([_detailPost.type isEqualToString: @"Free"]){
        [self.purchaseButton setTitle:@"Get" forState:UIControlStateNormal];
    } else {
        [self.purchaseButton setTitle:[NSString stringWithFormat:@"$%@", self.detailPost.price] forState:UIControlStateNormal];
        if ([_detailPost.type isEqualToString: @"Books"]){
            _bookForClassLabel.text = _detailPost[@"bookForClass"];
        }
        if ([_detailPost.type isEqualToString: @"Tickets"]){
            _eventDateForTicketLabel.text = _detailPost[@"eventDate"];
        }
    }
    
        [self addCoachMarks];
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
    UIAlertController *contactMethod = [UIAlertController alertControllerWithTitle:@"Select communication method" message:@"How would you like to contact the seller?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"Phone" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.poster[@"phoneNumber"] != nil){
            NSString *phoneNumber = [@"telprompt://" stringByAppendingString:[self.poster objectForKey:@"phoneNumber"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No phone number found" message:@"Poster failed to provide required contact information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alert.tag = 0;
            [alert show];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }]
     ];
    
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"SMS" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([MFMessageComposeViewController canSendText] && self.poster[@"phoneNumber"]){
            MFMessageComposeViewController *textMessageViewController = [[MFMessageComposeViewController alloc] init];
            textMessageViewController.messageComposeDelegate = self;
            NSString *phoneNumber = (NSString *)self.poster[@"phoneNumber"];
            [textMessageViewController setRecipients:@[phoneNumber]];
            [textMessageViewController setBody:[NSString stringWithFormat:@"Hi %@, I'm interested in your \"%@\" on Spree", [self.poster[@"name"] componentsSeparatedByString:@" "], self.detailPost.title]];
            textMessageViewController.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:textMessageViewController animated:YES completion:nil];
        } else {
            UIAlertView *cannotSendMessageAlert = [[UIAlertView alloc] initWithTitle:@"Unable to send message" message:@"Sorry, your phone is not set up to send SMS or the seller did not provide adequate contact information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [cannotSendMessageAlert show];
        }
    }]
     ];
    
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
            [composeViewController setMailComposeDelegate:self];
            NSLog(@"%@", self.poster);
            [composeViewController setToRecipients:@[self.poster[@"email"]]];
            [composeViewController setSubject:[NSString stringWithFormat:@"Post on Spree: %@", _detailPost.title]];
            [composeViewController setMessageBody:[NSString stringWithFormat:@"Hi %@,\n\n I'm interested in your '%@' on Spree.",  [[_poster[@"name"] componentsSeparatedByString:@" "] objectAtIndex:0], _detailPost.title]isHTML:NO];
            composeViewController.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:composeViewController animated:YES completion:nil];
        } else {
            NSString *message = [NSString stringWithFormat:@"You have not set up Mail on iPhone. User's email is %@", _poster[@"email"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Phone cannot send email" message:message  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Copy email to clipboard", nil];
            alert.tag = 1;
            [alert show];
        }
    }]
     ];
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]
     ];
    
    [self presentViewController:contactMethod animated:YES completion:nil];
}

- (IBAction)infoBarButtonItemPressed:(id)sender {
  UIAlertController *contactMethod = [UIAlertController alertControllerWithTitle:@"Post information" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"Ask for more information" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self purchaseButtonPressed:self];
    }]
     ];
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]
     ];
    [self presentViewController:contactMethod animated:YES completion:nil];
    
}

# pragma mark - UIAlertView methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 1:
            if (buttonIndex == 1){
                [self.detailPost deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error){
                        if (succeeded == YES)
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"PostDeleted" object:nil];
                    }
                }];
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        case 2:
            if (buttonIndex == 1){
                [self.detailPost setSold:YES];
                [self.detailPost saveInBackground];
                [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Message delegates

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (error){
        NSString *errorTitle = @"Mail Error";
        NSString *errorDescription = [error localizedDescription];
        UIAlertView *errorView = [[UIAlertView alloc]initWithTitle:errorTitle message:errorDescription delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        errorView.tag = 2;
        [errorView show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
