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
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    cancel.backgroundColor = [UIColor clearColor];
    cancel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancel setImage:[UIImage imageNamed:@"backNormal_Dark"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"backHighlight_Dark"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)backButtonTouched{
    [self.delegate logInAuthorizationViewControllerWentBackwards:self];
}

- (IBAction)authorizeButtonTapped:(id)sender {
    
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            // Process error
        } else if (result.isCancelled) {
            // Handle cancellations
        } else {
            FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
            // Link PFUser with FBSDKAccessToken
            [PFFacebookUtils linkUserInBackground:[PFUser currentUser]
                                  withAccessToken:accessToken
                                            block:^(BOOL succeeded, NSError *error) {
                                                if (succeeded) {
                                                    NSLog(@"Woohoo, the user is linked with Facebook!");
                                                }
                                            }];

        }
    }];
    
//    
//    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//        [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withAccessToken:[ block:<#(nullable PFBooleanResultBlock(nullable )block#>]
//        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:@[@"user_friends",@"publish_actions",@"user_managed_groups"] block:^(BOOL succeeded, NSError *error){
//            if (succeeded){
//                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
//                // Send request to Facebook
//                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                    NSLog(@"1.5");
//                    if (!error) {
//                        NSLog(@"2");
//                        NSLog(@"currentUser: %@",[PFUser currentUser]);
//                        NSLog(@"result: %@",result);
//                        // Store the current user's Facebook ID on the user
//                        [[PFUser currentUser] setObject:[result objectForKey:@"id"]
//                                                 forKey:@"fbId"];
//                        [[PFUser currentUser] saveInBackground];
//                        [self fetchBasicInfo];
//                        NSLog(@"ACCESS %@", [FBSDKAccessToken currentAccessToken]);
//                        [self.delegate logInAuthorizationViewController:self didAuthorizeFacebookForUser:self.user];
//                    } else {
//                        NSLog(@"3, %@",error);
//                    }
//                }];
//            } else {
//                NSLog(@"%@", error);
//                [self.delegate logInAuthorizationViewController:self didFailToAuthorizeFacebookForUser:self.user];
//            }
//        }];
//        
//    }
}

- (IBAction)optOutButtonTapped:(id)sender {
    [self.delegate logInAuthorizationViewController:self userDidOptOut:self.user];
}

-(void)fetchBasicInfo{

    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/picture?type=large&redirect=false" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"%@", result);
                 UIImage *profileImage = [[UIImage alloc] initWithData:result];
                 self.profileImageView.image = profileImage;
             } else {
                 NSLog(@"%@", error);
             }
         }];
    }
}


@end
