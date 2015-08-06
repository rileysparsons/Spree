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
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    cancel.backgroundColor = [UIColor clearColor];
    cancel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancel setImage:[UIImage imageNamed:@"backNormal_Dark"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"backHighlight_Dark"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
}

-(void)backButtonTouched{
    self.loginWorkflow.step--;
    [self.navigationController popViewControllerAnimated:YES];
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

- (BOOL)didFailToCompleteWorkflow:(LoginWorkflow *)loginWorkflow withError:(NSError*)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles: nil];
    [alert show];
    return YES;
}

-(BOOL)didCompleteWorkflow:(LoginWorkflow *)loginWorkflow{
    NSLog(@"%@", self.navigationController.presentingViewController);
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    PostTableViewController *postTableViewController = [stb instantiateViewControllerWithIdentifier:@"home"];
    NSLog(@"%@", [stb instantiateInitialViewController]);
    [UIView transitionWithView:appDelegate.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ appDelegate.window.rootViewController = postTableViewController; }
                    completion:nil];
    return YES;
}


@end
