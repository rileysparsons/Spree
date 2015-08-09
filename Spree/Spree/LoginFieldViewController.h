//
//  LoginFieldViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/4/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginFieldViewController : UIViewController

@property UILabel *titleView;
@property UIButton *nextButton;

-(void)shakeAnimation:(UIView*) view;
-(void)backButtonTouched;
-(void)nextButtonTouched;

@end

