//
//  SecondViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "MeViewController.h"
#import "TextViewViewController.h"
#import "ContactUsViewController.h"
#import "SettingsViewController.h"
#import "SpreePost.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MSCellAccessory.h"
#import "RatingViewController.h"
#import "Branch/Branch.h"

#define kReferralTabTitle @"Referrals"

#import "SpreeUtility.h"

typedef enum : NSUInteger {
    kLogOutAlert,
    kVerifyEmailAlert
} AlertType;


#define kAuthorizeFacebookTitle @"Authorize Facebook"
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
    [SpreeUtility saveCurrentCreditBalance];
    [self.settingsTableView reloadData];
}

-(void)networkLabelText{
    [[PFUser currentUser][@"campus"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
        self.networkLabel.text = [NSString stringWithFormat:@"%@", [PFUser currentUser][@"campus"][@"campusName"]];
        
    }];
}

-(void)updateTableView{
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        _firstSectionArray = [[NSArray alloc] initWithObjects: kYourPostsTitle, kReferralTabTitle, kLogOutTitle, nil];
    } else {
        _firstSectionArray = [[NSArray alloc] initWithObjects: kAuthorizeFacebookTitle, kYourPostsTitle, kReferralTabTitle, kLogOutTitle, nil];
    }
//    [self.settingsTableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)viewWillAppear:(BOOL)animated{
    //Sets the bar button item in the top left equal to the value of credits the user has
    
    [[Branch getInstance] loadRewardsWithCallback:^(BOOL changed, NSError *err) {
        if (!err) {
            NSString *credit = [NSString stringWithFormat:@"Credit: %lu", [[Branch getInstance] getCredits]];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:credit style:UIBarButtonItemStylePlain target:self action: @selector(creditButtonTouched:)];
        }
    }];
    
    PFQuery *expiredPostNumberQuery = [PFQuery queryWithClassName:@"Post"];
    [expiredPostNumberQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [expiredPostNumberQuery  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            NSMutableArray *expiredPosts = [[NSMutableArray alloc] init];
            NSMutableArray *activePosts = [[NSMutableArray alloc] init];
            
            for (SpreePost *post in objects){
                if (post.expired == YES){
                    [expiredPosts addObject:post];
                } else {
                    [activePosts  addObject:post];
                }
            }
            expiredPostCount = expiredPosts.count;
            activePostCount = activePosts.count;
            if (activePostCount != 0){
                self.postCountLabel.text = [NSString stringWithFormat:@"%ld active posts", (long)activePostCount];
            } else {
                self.postCountLabel.text = @"No active posts";
            }
            [self.settingsTableView reloadData];
        }
    }];
    if (expiredPostCount != 0){
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%li", (long)expiredPostCount];
    } else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
}

-(void)setUserInfo{
    self.nameLabel.enabled = NO;
    self.nameLabel.labeledIconButtonLayoutMode = RCSLabeledIconButtonLayoutModeReversed;
    [self.nameLabel setTitleColor:[UIColor spreeOffBlack] forState:UIControlStateNormal];
    self.nameLabel.titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:17];
    self.nameLabel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (![SpreeUtility userInDemoMode]){
        
        if ([SpreeUtility checkForEmailVerification]){
            if ([PFUser currentUser][@"displayName"]){
                self.profileImageView.profileID = [PFUser currentUser][@"fbId"];
                 [self.nameLabel setTitle:[PFUser currentUser][@"displayName"] forState:UIControlStateNormal];
            } else {
                [self.nameLabel setTitle:[PFUser currentUser][@"username"] forState:UIControlStateNormal];
            }
            
            [self.nameLabel setImage:[UIImage imageNamed:@"verifiedStudent"] forState:UIControlStateNormal];
        } else {
            
            UIAlertView *userNotVerified = [[UIAlertView alloc] initWithTitle:@"Unverified Student" message:VERIFY_EMAIL_PROMPT delegate:self cancelButtonTitle:@"OK" otherButtonTitles: @"Resend email", nil];
            userNotVerified.tag = kVerifyEmailAlert;
            [userNotVerified show];
            
            if ([PFUser currentUser][@"displayName"]){
                self.profileImageView.profileID = [PFUser currentUser][@"fbId"];
                 [self.nameLabel setTitle:[PFUser currentUser][@"displayName"] forState:UIControlStateNormal];
            } else {
                [self.nameLabel setTitle:[PFUser currentUser][@"username"] forState:UIControlStateNormal];
            }
        }
    } else {
        [self.nameLabel setTitle:@"Demo Mode" forState:UIControlStateNormal];
    }
    
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
     } else if ( [[self.firstSectionArray objectAtIndex:indexPath.row] isEqualToString:kAuthorizeFacebookTitle]){
         return [self authorizeFacebookTableViewCell];
     } else  if ( [[self.firstSectionArray objectAtIndex:indexPath.row] isEqualToString:kYourPostsTitle]){
         return [self yourPostsTableViewCell];
     } else  if ( [[self.firstSectionArray objectAtIndex:indexPath.row] isEqualToString:kReferralTabTitle]){
         return [self referralTableViewCell];
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
            [[Branch getInstance] logout];
            confirmLogOut.tag = 0;
            [confirmLogOut show];
            
        } else if ([titleOfRow isEqualToString: kYourPostsTitle]){
            [self performSegueWithIdentifier:@"ShowUserPosts" sender:self];
        } else if ([titleOfRow isEqualToString: kReferralTabTitle]){
            [self performSegueWithIdentifier:@"ShowReferralView" sender:self];
            //BranchReferralController *referralController = [BranchReferralController branchReferralControllerWithView:myCustomView delegate:self];
            //BranchReferralController *referralController = [BranchReferralController branchReferralControllerWithDelegate:self];
            //[self presentViewController:referralController animated:YES completion:NULL];
        }
        else if ([titleOfRow isEqualToString:kAuthorizeFacebookTitle]){
            NSLog(@"CALLED");
            [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:nil block:^(BOOL succeeded, NSError *error){
                if (succeeded){
                    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
                    //                         Send request to Facebook
                    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            NSLog(@"2");
                            NSLog(@"currentUser: %@",[PFUser currentUser]);
                            NSLog(@"result: %@",result);
                            // Store the current user's Facebook ID on the user
                            [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                                     forKey:@"fbId"];
                            [[PFUser currentUser] saveInBackground];
                            NSLog(@"ACCESS %@", [FBSDKAccessToken currentAccessToken]);
                            
                            
                            
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.firstSectionArray indexOfObject:kAuthorizeFacebookTitle] inSection:0];
                            [self updateTableView];
                            [self.settingsTableView beginUpdates];
                            [self.settingsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                            [self.settingsTableView endUpdates];
                            
                        } else {
                            NSLog(@"3, %@",error);
                        }
                    }];
                    
                }
            }];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showTerms"]) {
        TextViewViewController *destination = (TextViewViewController*)segue.destinationViewController;
        destination.textDisplayed = @"By logging into and using this application you are accepting responsibility for what you post and the interactions (communications, meet-ups, etc.) that emerge from the use of this service.\n\nSpree will not be held liable for any harm, theft, damages or liabilities that are facilitated by the use of Spree.\n\nYou may not sell anything illegal or anything that is explicit in nature through our service. You agree that you will abide by the rules, regulations and laws of your state when using this application.";
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kLogOutAlert){
        if (buttonIndex == 1) {
#warning REMOVE BEFORE SUBMISSION
                [[Branch getTestInstance] logout];
                [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
        }
    } else if (alertView.tag == kVerifyEmailAlert){
        int resendButtonIndex = 1;
        if (resendButtonIndex == buttonIndex){
            //updating the email will force Parse to resend the verification email
            NSString *email = [[PFUser currentUser] objectForKey:@"email"];
            NSLog(@"email: %@",email);
            [[PFUser currentUser] setObject:email forKey:@"email"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error ){
                
                if( succeeded ) {
                    
                    [[PFUser currentUser] setObject:email forKey:@"email"];
                    [[PFUser currentUser] saveInBackground];
                    
                }
                
            }];
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

-(UITableViewCell *)referralTableViewCell{
    UITableViewCell *referralCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kReferralTabTitle];
    referralCell.detailTextLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15];
    referralCell.detailTextLabel.textColor =[UIColor spreeDarkBlue];
    referralCell.textLabel.text = kReferralTabTitle;
    referralCell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:18];
    referralCell.textLabel.textColor = [UIColor spreeOffBlack];
    referralCell.backgroundColor = [UIColor spreeOffWhite];
    [[Branch getInstance] loadRewardsWithCallback:^(BOOL changed, NSError *err) {
        if (!err) {
            referralCell.detailTextLabel.text = [NSString stringWithFormat:@"credit: %lu", [[Branch getInstance] getCredits]];
        }
    }];
    referralCell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeDarkBlue] highlightedColor:[UIColor spreeLightYellow]];
    return referralCell;
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

-(UITableViewCell *)authorizeFacebookTableViewCell{
    UITableViewCell *authorizeFacebookCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAuthorizeFacebookTitle];
    authorizeFacebookCell.textLabel.text = kAuthorizeFacebookTitle;
    authorizeFacebookCell.textLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18];
    authorizeFacebookCell.textLabel.textColor = [UIColor spreeDarkBlue];
    authorizeFacebookCell.backgroundColor = [UIColor spreeOffWhite];
    return authorizeFacebookCell;
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
