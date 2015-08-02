//
//  FinalOnboardingViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "RTWalkthroughPageViewController.h"

@interface FinalOnboardingViewController : RTWalkthroughPageViewController

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginButtonTapped:(id)sender;

@end
