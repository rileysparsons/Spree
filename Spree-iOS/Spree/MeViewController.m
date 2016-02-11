//
//  SecondViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "MeViewController.h"
#import "UserPostTableViewModel.h"
#import "TextViewViewController.h"
#import "ContactUsViewController.h"
#import "UserPostsTableViewController.h"
#import "SettingsViewController.h"
#import "SpreeViewModelServicesImpl.h"
#import "SpreePost.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MSCellAccessory.h"
#import "RatingViewController.h"
#import "Branch/Branch.h"

#import "SpreeUtility.h"

typedef enum : NSUInteger {
    kLogOutAlert
} AlertType;

#define kLogOutTitle @"Log Out"
#define kYourPostsTitle @"Your Posts"

@interface MeViewController () <UIAlertViewDelegate> {
    NSInteger expiredPostCount;
    NSInteger activePostCount;
}
@property NSArray *firstSectionArray;
@property NSArray *secondSectionArray;
@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitleLabel];
    
    [self updateTableView];
    
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    
    self.settingsTableView.backgroundColor = [UIColor clearColor];
   
    [self networkLabelText];
    
    [self setUserInfo];

    [self circularImage];
    // Add notification center for updating the posts cell for requests
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPurchaseRequest) name:@"NewRequest" object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateTableView];
    [self.settingsTableView reloadData];
}

-(void)networkLabelText{
    [[PFUser currentUser][@"campus"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
        self.networkLabel.text = [NSString stringWithFormat:@"%@", [PFUser currentUser][@"campus"][@"campusName"]];
        
    }];
}

-(void)updateTableView{
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        _firstSectionArray = [[NSArray alloc] initWithObjects: kYourPostsTitle, kLogOutTitle, nil];
    } else {
        _firstSectionArray = [[NSArray alloc] initWithObjects: kYourPostsTitle, kLogOutTitle, nil];
    }
//    [self.settingsTableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)viewWillAppear:(BOOL)animated{

    PFQuery *activePostNumberQuery = [PFQuery queryWithClassName:@"Post"];
    [activePostNumberQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [activePostNumberQuery whereKeyDoesNotExist:@"removed"];
    [activePostNumberQuery whereKey:@"expired" equalTo:[NSNumber numberWithBool:0]];
    [activePostNumberQuery whereKey:@"sold" equalTo:[NSNumber numberWithBool:0]];
    [activePostNumberQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error){
        if (!error){
            activePostCount = number;
            if (activePostCount != 0){
                self.postCountLabel.text = [NSString stringWithFormat:@"%ld active posts", (long)activePostCount];
            } else {
                self.postCountLabel.text = @"No active posts";
            }

        }
    }];
    
    PFQuery *expiredPostNumberQuery = [PFQuery queryWithClassName:@"Post"];
    [expiredPostNumberQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [expiredPostNumberQuery whereKeyDoesNotExist:@"removed"];
    [expiredPostNumberQuery whereKey:@"expired" equalTo:[NSNumber numberWithBool:1]];
    [expiredPostNumberQuery whereKey:@"sold" equalTo:[NSNumber numberWithBool:0]];
    [expiredPostNumberQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error){
            expiredPostCount = number;
            if (expiredPostCount != 0){
                self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%li", (long)expiredPostCount];
            } else {
                self.navigationController.tabBarItem.badgeValue = nil;
            }
            [self.settingsTableView reloadData];
        }
    }];
}

-(void)setUserInfo{
    self.nameLabel.font = [UIFont fontWithName:@"Lato-Regular" size:17];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.textColor = [UIColor spreeOffBlack];
    self.profileImageView.profileID = [PFUser currentUser][@"fbId"];
    @weakify(self)
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"email,name,first_name"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        @strongify(self)
        [self.nameLabel setText:result[@"name"]];
    }];
    
    
//    if ([[PFUser currentUser][@"emailVerified"] isEqualToNumber:[NSNumber numberWithBool:1]]){
//        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
//            self.profileImageView.profileID = [PFUser currentUser][@"fbId"];
//            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me?fields=name" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                [self.nameLabel setTitle:result[@"name"] forState:UIControlStateNormal];
//            }];
//        } else {
//            [self.nameLabel setTitle:[PFUser currentUser][@"username"] forState:UIControlStateNormal];
//        }
//        
//        [self.nameLabel setImage:[UIImage imageNamed:@"verifiedStudent"] forState:UIControlStateNormal];
//    } else {
//        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
//            self.profileImageView.profileID = [PFUser currentUser][@"fbId"];
//            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me?fields=name" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                [self.nameLabel setTitle:result[@"name"] forState:UIControlStateNormal];
//            }];
//        } else {
//            [self.nameLabel setTitle:[PFUser currentUser][@"username"] forState:UIControlStateNormal];
//        }
//    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0){
        return [_firstSectionArray count];
    }
    return 0;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     if ([[self.firstSectionArray objectAtIndex:indexPath.row] isEqualToString:kLogOutTitle]){
         return [self logOutTableViewCell];
     } else if ( [[self.firstSectionArray objectAtIndex:indexPath.row] isEqualToString:kYourPostsTitle]){
         return [self yourPostsTableViewCell];
     }
     
     return 0;
 }

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *titleOfRow = [self.settingsTableView cellForRowAtIndexPath:indexPath].textLabel.text;
    if (indexPath.section == 0){
        if ([titleOfRow isEqualToString:kLogOutTitle]){
//            [PFFacebookUtils unlinkUser:[PFUser currentUser]];
            UIAlertView *confirmLogOut = [[UIAlertView alloc] initWithTitle:@"Confirm Log Out" message:@"Are you sure you want to log out of Spree?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            confirmLogOut.tag = 0;
            [confirmLogOut show];
            
        } else if ([titleOfRow isEqualToString: kYourPostsTitle]){
            [self performSegueWithIdentifier:@"ShowUserPosts" sender:self];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showTerms"]) {
        TextViewViewController *destination = (TextViewViewController*)segue.destinationViewController;
        destination.textDisplayed = @"By logging into and using this application you are accepting responsibility for what you post and the interactions (communications, meet-ups, etc.) that emerge from the use of this service.\n\nSpree will not be held liable for any harm, theft, damages or liabilities that are facilitated by the use of Spree.\n\nYou may not sell anything illegal or anything that is explicit in nature through our service. You agree that you will abide by the rules, regulations and laws of your state when using this application.";
    } else if ([segue.identifier isEqualToString:@"ShowUserPosts"]){
        UserPostsTableViewController *userPostsTableViewController = (UserPostsTableViewController *)segue.destinationViewController;
        // Attaching View Model Services to View Model (gives us access to Parse, our model)
        SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
        UserPostTableViewModel *viewModel = [[UserPostTableViewModel alloc] initWithServices:viewModelServices user:[PFUser currentUser] params:nil];
        userPostsTableViewController.viewModel = viewModel;
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kLogOutAlert){
        if (buttonIndex == 1) {
                [[Branch getInstance] logout];
                [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
        }
    }
}


- (IBAction)creditButtonTouched:(id)sender {
    
    [self performSegueWithIdentifier:@"ShowReferralView" sender:self];
}


- (IBAction)settingsButtonTouched:(id)sender {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsViewController animated:YES];
    
}

-(UITableViewCell *)logOutTableViewCell{
    UITableViewCell *logOutCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLogOutTitle];
    logOutCell.textLabel.text = kLogOutTitle;
    logOutCell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:18];
    logOutCell.textLabel.textColor = [UIColor spreeRed];
    logOutCell.backgroundColor = [UIColor spreeOffWhite];
    return logOutCell;
}

-(UITableViewCell *)yourPostsTableViewCell{
    UITableViewCell *yourPostsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kYourPostsTitle];
    yourPostsCell.detailTextLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15];
    yourPostsCell.textLabel.text = kYourPostsTitle;
    yourPostsCell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:18];
    yourPostsCell.textLabel.textColor = [UIColor spreeOffBlack];
    yourPostsCell.backgroundColor = [UIColor spreeOffWhite];
    yourPostsCell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeDarkBlue] highlightedColor:[UIColor spreeLightYellow]];
    if (expiredPostCount != 0){
        yourPostsCell.detailTextLabel.textColor = [UIColor spreeOffBlack];
        if (expiredPostCount == 1) {
            yourPostsCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld expired post!", (long)expiredPostCount];
        } else {
            yourPostsCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld expired posts!", (long)expiredPostCount];
        }
    } else {
        yourPostsCell.detailTextLabel.textColor = [UIColor spreeDarkBlue];
        yourPostsCell.detailTextLabel.text = @"All posts are active";
    }
    
    return yourPostsCell;
}

-(void)circularImage{
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.profileImageView.frame.size.width, self.profileImageView.frame.size.height) cornerRadius:MAX(self.profileImageView.frame.size.width, self.profileImageView.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor spreeOffWhite].CGColor;
    circle.strokeColor = [UIColor spreeOffWhite].CGColor;
    circle.lineWidth = 0;
    self.profileImageView.layer.mask=circle;
}

- (void)setTitleLabel {
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text= @"ME";
    titleLabel.textColor=[UIColor spreeOffBlack];
    titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size: 17.0];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=titleLabel;
}

@end
