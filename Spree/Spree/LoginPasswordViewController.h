//
//  LoginPasswordViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginFieldViewController.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

@protocol LoginPasswordViewControllerDelegate;

@interface LoginPasswordViewController : LoginFieldViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property id<LoginPasswordViewControllerDelegate> delegate;
@property PFUser *user;
@property BOOL userIsNew;

@end

@protocol LoginPasswordViewControllerDelegate <NSObject>

@optional

///--------------------------------------
/// @name Customizing Behavior
///--------------------------------------

- (BOOL)logInViewController:(LoginPasswordViewController *)logInController
  shouldBeginLogInWithPassword:(NSString *)password;

- (BOOL)signupViewController:(LoginPasswordViewController *)signupController shouldBeginSignInWithPassword:(NSString *)password;

///--------------------------------------
/// @name Responding to Actions
///--------------------------------------

- (void)logInViewController:(LoginPasswordViewController *)logInController didLogInUser:(PFUser *)user;


- (void)logInViewController:(LoginPasswordViewController *)logInController
didFailToLogInWithError:(NSError *)error;

- (void)logInViewControllerWentBackwards:(LoginPasswordViewController *)logInController;

- (void)signupViewController:(LoginPasswordViewController *)signupController didSignUpUser:(PFUser *)user;

- (void)signupViewController:(LoginPasswordViewController *)signupController
    didFailToSignUpWithError:(NSError *)error;

@end

