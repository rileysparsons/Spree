//
//  LoginFieldViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/4/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginWorkflow.h"


@interface LoginFieldViewController : UIViewController <LoginWorkflowDelegate>

@property LoginWorkflow *loginWorkflow;

-(void)shakeAnimation:(UIView*) view;
-(void)backButtonTouched;

@end

