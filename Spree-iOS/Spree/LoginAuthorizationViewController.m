//
//  LoginAuthorizationViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "LoginAuthorizationViewController.h"
#import "AppDelegate.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "PostTableViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginAuthorizationViewController ()

@end

@implementation LoginAuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)authorizeButtonTapped:(id)sender {
    
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
                                                    [self fetchBasicInfo];
                                                    NSLog(@"ACCESS %@", [FBSDKAccessToken currentAccessToken]);
                                                    [self.delegate logInAuthorizationViewController:self didAuthorizeFacebookForUser:self.user];
                                                } else {
                                                    NSLog(@"3, %@",error);
                                                }
                    }];
                
                }
    }];
}

- (IBAction)optOutButtonTapped:(id)sender {
    [self.delegate logInAuthorizationViewController:self userDidOptOut:self.user];
}

-(void)fetchBasicInfo{
    self.profileImageView.profileID = [PFUser currentUser][@"fbId"];
}


@end
