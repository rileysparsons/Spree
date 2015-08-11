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
    
    
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    
    self.settingsTableView.backgroundColor = [UIColor clearColor];
    
    _firstSectionArray = [[NSArray alloc] initWithObjects:@"Log out", @"Your posts", nil];
    
    self.nameLabel.text = [PFUser currentUser][@"name"];

    [self loadFacebookInformation];
    

    // Add notification center for updating the posts cell for requests
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPurchaseRequest) name:@"NewRequest" object:nil];
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.settingsTableView.frame.size.width, 35)];
    UIColor *typeBackgroundColor = [UIColor spreeOffWhite];
    
    // Background color
    headerView.backgroundColor = typeBackgroundColor;
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.settingsTableView.bounds.size.width, 35)];
    whiteView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4f];
    [headerView addSubview:whiteView];
    
    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, whiteView.frame.size.width, whiteView.frame.size.height
                                                                     )];
    labelHeader.font = [UIFont fontWithName:@"Helvetica" size:16];
    labelHeader.textColor = [UIColor spreeOffBlack];
    
    [whiteView addSubview:labelHeader];
    
    if (section == 0) {
        labelHeader.text = @"Settings";
    }
    
    
    return headerView;
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
    
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
     // Configure the cell...
     static NSString *CellIdentifier = @"Cell";
     
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
     }
     
     if (indexPath.section == 0){
         cell.textLabel.text = [_firstSectionArray objectAtIndex:indexPath.row];
         if (indexPath.row == 1) {
             cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeDarkBlue] highlightedColor:[UIColor grayColor]];
             if (expiredPostCount != 0){
                 cell.detailTextLabel.textColor = [UIColor spreeOffBlack];
                 if (expiredPostCount == 1) {
                     cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld expired post!", (long)expiredPostCount];
                 } else {
                     cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld expired posts!", (long)expiredPostCount];
                 }
             } else {
                 cell.detailTextLabel.textColor = [UIColor spreeDarkBlue];
                 cell.detailTextLabel.text = @"All posts are active";
             }
         }
     }
     return cell;
 }

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        if (indexPath.row == 0){
//            [PFFacebookUtils unlinkUser:[PFUser currentUser]];
            UIAlertView *confirmLogOut = [[UIAlertView alloc] initWithTitle:@"Confirm Log Out" message:@"Are you sure you want to log out of Spree?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            confirmLogOut.tag = 0;
            [confirmLogOut show];
        } else if (indexPath.row == 1){
            [self performSegueWithIdentifier:@"ShowUserPosts" sender:self];
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
            [PFUser logOut];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
            UINavigationController *base = [stb instantiateViewControllerWithIdentifier:@"base"];
            [UIView transitionWithView:appDelegate.window
                              duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{ appDelegate.window.rootViewController = base; }
                            completion:nil];
        }
    }
}

- (IBAction)settingsButtonTouched:(id)sender {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}
@end
