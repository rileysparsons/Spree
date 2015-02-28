//
//  LoginViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "LoginViewController.h"
#import "NewUserViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface LoginViewController () <NewUserViewControllerDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _loginWithFacebookButton.layer.cornerRadius = _loginWithFacebookButton.frame.size.height/2;
//    _loginWithFacebookButton.layer.bounds = CGRectMake(-10, -10, _loginWithFacebookButton.bounds.size.width+10, _loginWithFacebookButton.bounds.size.height+10);
//    _loginWithFacebookButton.layer.borderColor=[[UIColor whiteColor]CGColor];
//    _loginWithFacebookButton.layer.borderWidth= 1.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)newUserViewControllerDidSignup:(NewUserViewController *)controller{
    [self.delegate loginViewControllerDidLogin:self];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginButtonPressed:(id)sender {
    [self.view setUserInteractionEnabled:NO];
    // Set up activity view
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error) {
        if (!user) {
            // Hide the activity view
            NSString *alertMessage, *alertTitle;
            if (error) {
                FBErrorCategory errorCategory = [FBErrorUtility errorCategoryForError:error];
                if ([FBErrorUtility shouldNotifyUserForError:error]) {
                    // If the SDK has a message for the user, surface it.
                    alertTitle = @"Something Went Wrong";
                    alertMessage = [FBErrorUtility userMessageForError:error];
                } else if (errorCategory == FBErrorCategoryAuthenticationReopenSession) {
                    // It is important to handle session closures. We notify the user.
                    alertTitle = @"Session Error";
                    alertMessage = @"Your current session is no longer valid. Please log in again.";
                } else if (errorCategory == FBErrorCategoryUserCancelled) {
                    // The user has cancelled a login. You can inspect the error
                    // for more context. Here, we will simply ignore it.
                    NSLog(@"user cancelled login");
                } else {
                    // Handle all other errors in a generic fashion
                    alertTitle  = @"Unknown Error";
                    alertMessage = @"Error. Please try again later.";
                }
                
                if (alertMessage) {
                    [[[UIAlertView alloc] initWithTitle:alertTitle
                                                message:alertMessage
                                               delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil] show];
                }
            }
        } else {
            // Make a call to get user info
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                dispatch_block_t completion = ^{
                    // Show the logged in view
                    if ([PFUser currentUser].isNew){
                        [self presentNewUserViewController];
                    } else {
                        [self.delegate loginViewControllerDidLogin:self];
                    }
                };
                
                if (error) {
                    completion();
                } else {
                    // Save the name on Parse
                    [PFUser currentUser][@"name"] = user.name;
                    [PFUser currentUser][@"fbId"] = user.objectID;
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        completion();
                    }];
                    
                }
            }];
        }
    }];
    
}

- (IBAction)signUpPressed:(id)sender {
    [self presentNewUserViewController];
}

-(void)presentNewUserViewController{
    NewUserViewController *newUserViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewUserViewController"];
    newUserViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newUserViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
@end
