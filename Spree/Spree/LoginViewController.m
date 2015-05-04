//
//  LoginViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spreeIcon"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    [self.logInView setLogo:logoView];
    

    [self.logInView.passwordForgottenButton setTintColor:[UIColor spreeDarkBlue]];
    [self.logInView.signUpButton setTintColor:[UIColor colorWithWhite:.35f alpha:1]];

    [self.logInView.usernameField setTextColor:[UIColor spreeDarkBlue]];
    [self.logInView.passwordField setTextColor:[UIColor spreeDarkBlue]];
}

@end