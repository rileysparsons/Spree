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
    
    
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.secureTextEntry = YES;
    self.textField.placeholder = @"Enter Password";
//    [self.textField addRightButtonOnKeyboardWithText:@"Next" target:self action:@selector(nextBarButtonItemTouched:) shouldShowPlaceholder:YES];
    // Do any additional setup after loading the view.
}

- (void)nextBarButtonItemTouched:(id)sender {
    if (self.textField.text && self.textField.text.length != 0) {
        [self.loginWorkflow setPasswordForUser:self.textField.text];
        NSLog(@"%lu, %d", (unsigned long)self.loginWorkflow.viewControllersForFields.count, self.loginWorkflow.step+1);
        if (self.loginWorkflow.viewControllersForFields.count <= (self.loginWorkflow.step+1)){
            [self.loginWorkflow completeWorkflow];
        } else {
            NSLog(@"%@", self.textField.text);
            [self.navigationController pushViewController:[self.loginWorkflow nextViewController] animated:YES];
        }
    } else {
        [self shakeAnimation:self.textField];
        //        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
        //                                    message:@"Make sure you fill out all of the information!"
        //                                   delegate:nil
        //                          cancelButtonTitle:@"ok"
        //                          otherButtonTitles:nil] show];
    }
}

@end
