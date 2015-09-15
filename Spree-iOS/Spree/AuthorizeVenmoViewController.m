//
//  AuthorizeVenmoViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 9/14/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "AuthorizeVenmoViewController.h"
#import "ChatView.h"
#import "SpreeUtility.h"
#import <Venmo-iOS-SDK/Venmo.h>

@interface AuthorizeVenmoViewController ()

@end

@implementation AuthorizeVenmoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)linkVenmoButtonTouched:(id)sender {
    [[Venmo sharedInstance] requestPermissions:@[VENPermissionMakePayments,
                                                 VENPermissionAccessProfile]
                         withCompletionHandler:^(BOOL success, NSError *error) {
                             if (success) {
                                 [[PFUser currentUser] setObject:[[Venmo sharedInstance]session].user.externalId forKey:@"venmoId"];
                                 [[PFUser currentUser] saveInBackground];
                                 [self.delegate userDidAuthorizeVenmo];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }
                             else {
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authorization failed"
                                                                                     message:error.localizedDescription
                                                                                    delegate:self
                                                                           cancelButtonTitle:nil
                                                                           otherButtonTitles:@"OK", nil];
                                 [alertView show];
                                 [self.delegate userDidNotAuthorizeVenmo];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                             }
                         }];
}

- (IBAction)notNowButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [(ChatView *)self.presentingViewController.view setInputAccessoryView];
}

@end
