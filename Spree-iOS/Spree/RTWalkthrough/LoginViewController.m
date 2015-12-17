//
//  FinalOnboardingViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "LoginViewController.h"


@interface LoginViewController ()


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.viewModel);
    // Do any additional setup after loading the view.
    [self bindViewModel];
}

- (void)bindViewModel{
    self.loginButton.rac_command = self.viewModel.loginWithFacebook;
}

@end
