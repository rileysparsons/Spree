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
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spreeLogoWithName"]];
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
    
    [self.logInView.dismissButton setFrame:CGRectMake(10.0f, 10.0f, 87.5f, 45.5f)];
    [self.logInView.logo setFrame:CGRectMake(0, 30, self.logInView.bounds.size.width, 150)];
    [self.logInView.logo setContentMode:UIViewContentModeScaleAspectFit];
    [self.logInView.usernameField setFrame:CGRectMake(35.0f, 30+150+30, 250.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(35.0f, 30+150+30+50, 250.0f, 50.0f)];
     [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 30+150+20+70+50+60+60, 250.0f, 40.0f)];
    [self.logInView.logInButton setFrame:CGRectMake(35.0f, 30+150+20+70+50+60, 250.0f, 40.0f)];
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(35.0f, 30+150+20+70+50, 250.0f, 40.0f)];
    
}

@end