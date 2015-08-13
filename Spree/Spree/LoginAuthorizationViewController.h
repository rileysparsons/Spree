//
//  LoginAuthorizationViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@protocol LoginAuthorizationViewControllerDelegate;


@interface LoginAuthorizationViewController : UIViewController <UITextFieldDelegate>



@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *profileImageView;
@property PFUser *user;
@property id<LoginAuthorizationViewControllerDelegate> delegate;

- (IBAction)optOutButtonTapped:(id)sender;
- (IBAction)authorizeButtonTapped:(id)sender;


@end

@protocol LoginAuthorizationViewControllerDelegate <NSObject>

@optional

- (void)logInAuthorizationViewController:(LoginAuthorizationViewController *)logInController didAuthorizeFacebookForUser:(PFUser *)user;

- (void)logInAuthorizationViewController:(LoginAuthorizationViewController *)logInController didFailToAuthorizeFacebookForUser:(PFUser *)user;

- (void)logInAuthorizationViewControllerWentBackwards:(LoginAuthorizationViewController *)authorizationController;

- (void)logInAuthorizationViewController:(LoginAuthorizationViewController *)authorizationController userDidOptOut:(PFUser *)user;





@end

