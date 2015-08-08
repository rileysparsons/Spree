//
//  BaseOnboardingViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTWalkthroughViewController.h"
#import "LoginEmailViewController.h"
#import "LoginPasswordViewController.h"
#import "LoginAuthorizationViewController.h"
#import "LoginCampusTableViewController.h"

@interface BaseOnboardingViewController : UIViewController <RTWalkthroughViewControllerDelegate, LoginAuthorizationViewControllerDelegate, LoginEmailViewControllerDelegate, LoginPasswordViewControllerDelegate, LoginCampusTableViewControllerDelegate>

-(void)startOnboarding;

@end
