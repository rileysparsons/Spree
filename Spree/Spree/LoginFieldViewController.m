//
//  LoginFieldViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/4/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "LoginFieldViewController.h"
#import "PostTableViewController.h"
#import "AppDelegate.h"

@interface LoginFieldViewController ()

@end
 
@implementation LoginFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    back.backgroundColor = [UIColor clearColor];
    back.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [back setImage:[UIImage imageNamed:@"backNormal_Dark"] forState:UIControlStateNormal];
    [back setImage:[UIImage imageNamed:@"backHighlight_Dark"] forState:UIControlStateHighlighted];
    [back addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
    UIButton *nextButton = [[UIButton alloc] init];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [nextButton sizeToFit];
    [nextButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
    [nextButton setTintColor:[UIColor spreeDarkBlue]];
    [nextButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithCustomView:nextButton]] animated:YES];
    
    self.titleView =[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    self.titleView.textAlignment = NSTextAlignmentCenter;
    self.titleView.textColor=[UIColor spreeOffBlack];
    self.titleView.font = [UIFont fontWithName:@"Lato-Regular" size: 18.0];
    self.titleView.backgroundColor =[UIColor clearColor];
    self.titleView.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=self.titleView;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)backButtonTouched{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)nextButtonTouched{

}


-(void)shakeAnimation:(UIView*) view {
    const int reset = 5;
    const int maxShakes = 6;
    
    //pass these as variables instead of statics or class variables if shaking two controls simultaneously
    static int shakes = 0;
    static int translate = reset;
    
    [UIView animateWithDuration:0.09-(shakes*.01) // reduce duration every shake from .09 to .04
                          delay:0.01f//edge wait delay
                        options:(enum UIViewAnimationOptions) UIViewAnimationCurveEaseInOut
                     animations:^{view.transform = CGAffineTransformMakeTranslation(translate, 0);}
                     completion:^(BOOL finished){
                         if(shakes < maxShakes){
                             shakes++;
                             
                             //throttle down movement
                             if (translate>0)
                                 translate--;
                             
                             //change direction
                             translate*=-1;
                             [self shakeAnimation:view];
                         } else {
                             view.transform = CGAffineTransformIdentity;
                             shakes = 0;//ready for next time
                             translate = reset;//ready for next time
                             return;
                         }
                     }];
}

@end
