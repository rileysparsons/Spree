//
//  LoginViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginViewControllerDidLogin:(LoginViewController *)controller;

@end

@interface LoginViewController : UIViewController

@property (nonatomic, weak) id <LoginViewControllerDelegate> delegate;
- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)signUpPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginWithFacebookButton;

@end
