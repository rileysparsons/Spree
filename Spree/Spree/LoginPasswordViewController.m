//
//  LoginPasswordViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "LoginPasswordViewController.h"
#import "AppDelegate.h"
#import "PostTableViewController.h"

@interface LoginPasswordViewController ()

@end

@implementation LoginPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textField.delegate = self;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.secureTextEntry = YES;
    self.textField.returnKeyType = UIReturnKeyGo;
    
    
//    [self.textField addRightButtonOnKeyboardWithText:@"Next" target:self action:@selector(nextBarButtonItemTouched :) shouldShowPlaceholder:YES];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    
    UILabel *titleView =[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor=[UIColor spreeOffBlack];
    titleView.font = [UIFont fontWithName:@"Lato-Regular" size: 18.0];
    titleView.backgroundColor =[UIColor clearColor];
    titleView.adjustsFontSizeToFitWidth=YES;
    
    if(self.userIsNew){
        self.promptLabel.text = @"Great, now enter a password.";
        titleView.text = @"Sign up";
        
    } else {
        self.promptLabel.text = @"Great, now enter your password.";
        titleView.text = @"Log in";
    }
    
    
    self.navigationItem.titleView = titleView;
}

-(void)backButtonTouched{
    [self.delegate logInViewControllerWentBackwards:self];
}

- (void)nextButtonTouched{
    if (!self.userIsNew){
        if ([self.delegate logInViewController:self shouldBeginLogInWithPassword:self.textField.text]){
            NSLog(@"%@", self.user.username);
            [PFUser logInWithUsernameInBackground:self.user.username password:self.textField.text block:^(PFUser *user, NSError *error)
             {
                 if (!error){
                     NSLog(@"login");
                     [self.delegate logInViewController:self didLogInUser:user];
                 } else  {
                     [self.delegate logInViewController:self didFailToLogInWithError:error];
                 }
             }];
        } else {
            [self shakeAnimation:self.textField];
        }
    } else {
        if ([self.delegate signupViewController:self shouldBeginSignInWithPassword:self.textField.text]){
            self.user.password = self.textField.text;
            [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self.delegate signupViewController:self didSignUpUser:self.user];
                } else  {
                    [self.delegate signupViewController:self didFailToSignUpWithError:error];
                }
            }];
        } else {
            [self shakeAnimation:self.textField];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self nextButtonTouched];
    return YES;
}

@end
