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
#import "SpreeUtility.h"

@interface LoginAuthorizationViewController (){
    int _facebookResponseCount;
    int _expectedFacebookResponseCount;
    NSMutableData *_profilePicData;
}

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

- (IBAction)optOutButtonTapped:(id)sender {
    [self.delegate logInAuthorizationViewController:self userDidOptOut:self.user];
}

- (IBAction)authorizeButtonTapped:(id)sender{
    [self linkCurrentUserCallbackWithResult:[PFUser currentUser]];
}

#pragma mark - ()

- (void)processedFacebookResponse {
    NSLog(@"Processed");
    // Once we handled all necessary facebook batch responses, save everything necessary and continue
    @synchronized (self) {
        _facebookResponseCount++;
        if (_facebookResponseCount != _expectedFacebookResponseCount) {
            return;
        }
    }
    _facebookResponseCount = 0;
    NSLog(@"done processing all Facebook requests");
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Failed save in background of user, %@", error);
        } else {
            NSLog(@"saved current parse user");
        }
    }];
}

- (void)linkCurrentUserCallbackWithResult:(PFObject *)linkedObject{
    // This fetches the most recent data from FB, and syncs up all data with the server including profile pic and friends list from FB.
    
    PFUser *currentParseUser = [PFUser currentUser];
    
    if (!currentParseUser) {
        NSLog(@"Current Parse user does not exist, logout");
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
//    if (![SpreeUtility userHasValidFacebookData:currentParseUser]) {
//        NSLog(@"User does not have valid facebook ID. PFUser's FBID: %@, FBSessions FBID: %@. logout", [currentParseUser objectForKey:kPAPUserFacebookIDKey], session.accessTokenData.userID);
//        [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
//        return;
//    }
    
    // Finished checking for invalid stuff
    // Refresh FB Session (When we link up the FB access token with the parse user, information other than the access token string is dropped
    // By going through a refresh, we populate useful parameters on FBAccessTokenData such as permissions.
    
    
    [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:nil block:^(BOOL succeeded, NSError *error){
        if (error) {
            NSLog(@"Failed to link user %@", error);
            return;
        }
        
        
        if (succeeded){
            //  Send request to Facebook
            self.profileImageView.profileID = [PFUser currentUser][@"fbId"];
            [currentParseUser setObject:[FBSDKAccessToken currentAccessToken].userID forKey:PF_USER_FACEBOOK_ID];
            
            _expectedFacebookResponseCount = 0;
            
            NSSet *permissions = [[FBSDKAccessToken currentAccessToken] permissions];
            
            NSLog(@"Permissions: %@", permissions);
            
            if ([permissions containsObject:@"public_profile"]) {
                // Logged in with FB
                // Create batch request for all the stuff
                FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc]init];
                _expectedFacebookResponseCount++;
                [connection addRequest:[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil] completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    if (error) {
                        // Failed to fetch me data.. logout to be safe
                        NSLog(@"couldn't fetch facebook /me data: %@, logout", error);
                        [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
                        return;
                    }
                    
                    NSString *facebookName = result[@"name"];
                    if (facebookName && [facebookName length] != 0) {
                        [currentParseUser setObject:facebookName forKey:@"displayName"];
                    }
                    
                    [self processedFacebookResponse];
                }];
            
                [connection start];
                [self.delegate logInAuthorizationViewController:self didAuthorizeFacebookForUser:self.user];
            } else {
                [currentParseUser setObject:@"Someone" forKey:@"displayName"];
                _expectedFacebookResponseCount++;
                [self processedFacebookResponse];
            }
        }
    }];

}

@end
