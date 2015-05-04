//
//  LoginViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "UIColor+SpreeColor.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spreeIcon"]];
    [self.logInView setLogo:logoView];

    [self.logInView.passwordForgottenButton setTintColor:[UIColor spreeDarkBlue]];
    self.logInView.backgroundColor = [UIColor whiteColor];
    [self.logInView.usernameField setTextColor:[UIColor spreeDarkBlue]];
    [self.logInView.passwordField setTextColor:[UIColor spreeDarkBlue]];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundColor:[UIColor colorWithWhite:.70f alpha:1]];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setBackgroundColor:[UIColor spreeBabyBlue]];

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.logInView.logo setFrame:CGRectMake(0, 30, self.logInView.bounds.size.width, 125)];
    [self.logInView.logo setContentMode:UIViewContentModeScaleAspectFit];
}

@end