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
#import "FinalOnboardingViewController.h"
#import "LoginCampusTableViewController.h"
#import "LoginAuthorizationViewController.h"
#import "PostTableViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "AppDelegate.h"

@interface BaseOnboardingViewController ()

@property LoginAuthorizationViewController *authorizationViewController;
@property LoginPasswordViewController *passwordViewController;
@property LoginEmailViewController *emailViewController;
@property LoginCampusTableViewController *campusViewController;
@property PFUser *user;
@property NSMutableArray *loginWorkflowViewControllers;

@end



@implementation BaseOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startOnboarding];
    [self prepareLoginWorkflow];
    self.user = [PFUser user];
    
    // Do any additional setup after loading the view.
}

-(void)prepareLoginWorkflow{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
    self.authorizationViewController =  [stb instantiateViewControllerWithIdentifier:NSStringFromClass([LoginAuthorizationViewController class])];
    [self.authorizationViewController setDelegate:self];
    self.passwordViewController =  [stb instantiateViewControllerWithIdentifier:NSStringFromClass([LoginPasswordViewController class])];
    [self.passwordViewController setDelegate:self];
    self.emailViewController = [stb instantiateViewControllerWithIdentifier:@"EmailInput"];
    [self.emailViewController setDelegate:self];
    self.campusViewController =
    [stb instantiateViewControllerWithIdentifier:NSStringFromClass([LoginCampusTableViewController class])];
    self.campusViewController.user = [PFUser user];
    [self.campusViewController setDelegate:self];
}

-(void)startOnboarding{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
    RTWalkthroughViewController *walkthrough = [stb instantiateViewControllerWithIdentifier:@"walk"];
    RTWalkthroughPageViewController *pageZero = [stb instantiateViewControllerWithIdentifier:@"walk0"];
    RTWalkthroughPageViewController *pageOne = [stb instantiateViewControllerWithIdentifier:@"walk1"];
    RTWalkthroughPageViewController *pageTwo = [stb instantiateViewControllerWithIdentifier:@"walk2"];
    FinalOnboardingViewController *final = [stb instantiateViewControllerWithIdentifier:NSStringFromClass(([FinalOnboardingViewController class]))];
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
    [self.navigationController pushViewController:self.campusViewController animated:YES];
}

-(BOOL)logInViewController:(LoginEmailViewController *)logInController shouldBeginLogInWithEmail:(NSString *)email{
    if (email && email.length != 0) {
        return YES;
    }
    return NO; // Interrupt login process
}

-(void)logInViewController:(LoginEmailViewController *)logInController didCheckEmail:(NSString *)email userExists:(BOOL)exists{
    if (exists){
        self.passwordViewController.userIsNew = NO;
    } else {
        self.passwordViewController.userIsNew = YES;
    }
    NSLog(@"%@", self.navigationController.viewControllers);
    self.passwordViewController.user = logInController.user;
    NSLog(@"%@", logInController.user);
    [self.navigationController pushViewController:self.passwordViewController animated:YES];
}

#pragma mark - LoginAuthorizationViewControllerDelegate Methods

- (void)logInAuthorizationViewController:(LoginAuthorizationViewController *)logInController didAuthorizeFacebookForUser:(PFUser *)user{


    
    [self closeOnboarding];
}

- (void)logInAuthorizationViewController:(LoginAuthorizationViewController *)logInController didFailToAuthorizeFacebookForUser:(PFUser *)user{
    [[[UIAlertView alloc] initWithTitle:@"Facebook Authorization Failed"
                                message:@"Something went wrong. Please try again."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)logInAuthorizationViewControllerWentBackwards:(LoginAuthorizationViewController *)authorizationController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)logInAuthorizationViewController:(LoginAuthorizationViewController *)authorizationController userDidOptOut:(PFUser *)user{
    [self closeOnboarding];
}

#pragma mark - LoginCampusTableViewController Method

-(void)loginCampusTableViewController:(LoginCampusTableViewController *)loginCampusTableViewController didSelectCampus:(PFObject *)campus{
    NSString *fullDomain = [NSString stringWithFormat:@"@%@.edu", campus[@"networkCode"]];
    self.emailViewController.domain = fullDomain;
    self.emailViewController.user = loginCampusTableViewController.user;
    NSLog(@"%@", loginCampusTableViewController.user);
    [self.navigationController pushViewController:self.emailViewController animated:YES];
}

#pragma mark - LoginPasswordViewControllerDelegate

-(BOOL)logInViewController:(LoginPasswordViewController *)logInController shouldBeginLogInWithPassword:(NSString *)password{
    NSLog(@"%@", password);
    if (password && password.length != 0) {
        return YES;
    }
    
    return NO; // Interrupt login process
}


-(void)logInViewController:(LoginPasswordViewController *)logInController didLogInUser:(PFUser *)user{
    if (![PFFacebookUtils isLinkedWithUser:user]){
        self.authorizationViewController.user = user;
        [self.navigationController pushViewController:self.authorizationViewController animated:YES];
    } else {
        [self closeOnboarding];
    }
}

- (void)logInViewController:(LoginPasswordViewController *)logInController
    didFailToLogInWithError:(NSError *)error{
    
}

-(void)logInViewControllerWentBackwards:(LoginPasswordViewController *)logInController{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)signupViewController:(LoginPasswordViewController *)signupController didSignUpUser:(PFUser *)user{
    [self incrementUserCountForCampus:user[@"campus"]];
    self.authorizationViewController.user = user;
    [self.navigationController pushViewController:self.authorizationViewController animated:YES];
}

-(void)signupViewController:(LoginPasswordViewController *)signupController didFailToSignUpWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"Sign Up Failed"
                                message:@"Something went wrong. Please try again."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (BOOL)signupViewController:(LoginPasswordViewController *)signupController shouldBeginSignInWithPassword:(NSString *)password{
    NSLog(@"%@", password);
    if (password && password.length != 0){
        return YES;
    }
    return NO;
}


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

#pragma mark - Base Methods

-(void)closeOnboarding{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    PostTableViewController *postTableViewController = [stb instantiateInitialViewController];
    [UIView transitionWithView:appDelegate.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ appDelegate.window.rootViewController = postTableViewController; }
                    completion:nil];
}

-(void)incrementUserCountForCampus:(PFObject *)campus{
    
    // Increment the current value of the quantity key by 1
    [campus incrementKey:@"userCount"];
    
    // Save
    [campus saveInBackground];
}


@end
