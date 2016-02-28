//
//  BaseOnboardingViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTWalkthroughViewController.h"
#import "LoginViewModel.h"

@interface BaseOnboardingViewController : UIViewController <RTWalkthroughViewControllerDelegate>

-(void)startOnboarding;

@property LoginViewModel *viewModel;

@end
