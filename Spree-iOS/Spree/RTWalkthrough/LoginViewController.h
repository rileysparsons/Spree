//
//  FinalOnboardingViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "RTWalkthroughPageViewController.h"
#import "LoginViewModel.h"

@interface LoginViewController : RTWalkthroughPageViewController

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property LoginViewModel *viewModel;

@end
