//
//  BaseOnboardingViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "BaseOnboardingViewController.h"
#import "RTWalkthroughPageViewController.h"
#import "RTWalkthroughViewController.h"
#import "LoginViewController.h"
#import "LoginViewModel.h"
#import "HomeViewController.h"
#import "SpreeViewModelServicesImpl.h"

#import "PostTableViewController.h"
#import "SpreeUtility.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "AppDelegate.h"

@interface BaseOnboardingViewController ()

@property PFUser *user;
@property NSMutableArray *loginWorkflowViewControllers;

@end



@implementation BaseOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startOnboarding];
    self.user = [PFUser user];
    
    // Do any additional setup after loading the view.
}


-(void)startOnboarding{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
    RTWalkthroughViewController *walkthrough = [stb instantiateViewControllerWithIdentifier:@"walk"];
    RTWalkthroughPageViewController *pageZero = [stb instantiateViewControllerWithIdentifier:@"walk0"];
    RTWalkthroughPageViewController *pageOne = [stb instantiateViewControllerWithIdentifier:@"walk1"];
    RTWalkthroughPageViewController *pageTwo = [stb instantiateViewControllerWithIdentifier:@"walk2"];
    
    LoginViewController *final = [stb instantiateViewControllerWithIdentifier:NSStringFromClass(([LoginViewController class]))];
    // Attaching View Model Services to View Model (gives us access to Parse, our model)
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];

    LoginViewModel *viewModel = [[LoginViewModel alloc] initWithServices: viewModelServices];
    // Linking view model to LoginViewController
    final.viewModel = viewModel;

    
    
    walkthrough.delegate = self;
    [walkthrough addViewController:pageOne];
    [walkthrough addViewController:pageTwo];
    [walkthrough addViewController:pageZero];
    [walkthrough addViewController:final];
    [self presentViewController:walkthrough animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)walkthroughControllerDidClose:(RTWalkthroughViewController *)controller{
    NSLog(@"called");
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
//    [self.navigationController pushViewController:self.campusViewController animated:YES];
    // This is where the login process begins.
}


#pragma mark - LoginAuthorizationViewControllerDelegate Methods
/*
-(void)signupViewController:(LoginPasswordViewController *)signupController didSignUpUser:(PFUser *)user{
    #warning REMOVE BEFORE SUBMISSION
    Branch *branch = [Branch getInstance];
    [branch setIdentity:[PFUser currentUser].objectId];
    
    [self incrementUserCountForCampus:user[@"campus"]];
    self.authorizationViewController.user = user;
    [self.navigationController pushViewController:self.authorizationViewController animated:YES];
}
*/
 
//// Sent to the delegate when a PFUser is signed up.
//- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
//    UIApplication* sharedApplication = [UIApplication sharedApplication];
//    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
//                                                    UIUserNotificationTypeBadge |
//                                                    UIUserNotificationTypeSound);
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
//                                                                             categories:nil];
//    [sharedApplication registerUserNotificationSettings:settings];
//    [sharedApplication registerForRemoteNotifications];
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//// Sent to the delegate when the sign up attempt fails.
//- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
//    NSLog(@"Failed to sign up...");
//}
//
//// Sent to the delegate when the sign up screen is dismissed.
//- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
//    NSLog(@"User dismissed the signUpViewController");
//}


@end
