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

#define kAuthorizeFacebookTitle @"Authorize Facebook"
#define kLogOutTitle @"Log Out"
#define kYourPostsTitle @"Your Posts"

@interface MeViewController () {
    NSInteger expiredPostCount;
    NSInteger activePostCount;
}
@property NSArray *firstSectionArray;
@property NSArray *secondSectionArray;
@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text= @"MORE";
    titleLabel.textColor=[UIColor spreeOffBlack];
    titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size: 17.0];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=titleLabel;
    
    [self updateTableView];
    
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    
    self.settingsTableView.backgroundColor = [UIColor clearColor];
    
    self.nameLabel.text = [PFUser currentUser][@"name"];


    [self loadFacebookInformation];
    

    // Add notification center for updating the posts cell for requests
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPurchaseRequest) name:@"NewRequest" object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateTableView];
    [self.settingsTableView reloadData];
}

-(void)updateTableView{
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        _firstSectionArray = [[NSArray alloc] initWithObjects: kYourPostsTitle, kLogOutTitle, nil];
    } else {
        _firstSectionArray = [[NSArray alloc] initWithObjects: kAuthorizeFacebookTitle, kYourPostsTitle, kLogOutTitle, nil];
    }
//    [self.settingsTableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)viewWillAppear:(BOOL)animated{
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

-(void)loadFacebookInformation{
    
    self.profileImageView.profileID = [PFUser currentUser][@"fbId"];

    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me?fields=name" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        self.nameLabel.text = result[@"name"];
    }];
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
        } else if ([titleOfRow isEqualToString:kAuthorizeFacebookTitle]){
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
    if (alertView.tag == 0){
        if (buttonIndex == 1) {
            [PFUser logOutInBackgroundWithBlock:^(NSError *error){
                [FBSDKAccessToken setCurrentAccessToken:nil];
                //            [FBSDKProfile setCurrentProfile:nil];
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
                UINavigationController *base = [stb instantiateViewControllerWithIdentifier:@"base"];
                [UIView transitionWithView:appDelegate.window
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionFlipFromLeft
                                animations:^{ appDelegate.window.rootViewController = base; }
                                completion:nil];
            }];
            
            //            [FBSDKAccessToken setCurrentAccessToken:nil];
//            [FBSDKProfile setCurrentProfile:nil];
        }
    }
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
    yourPostsCell.detailTextLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16];
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





@end
