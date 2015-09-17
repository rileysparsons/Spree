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
    
}

- (IBAction)notNowButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [(ChatView *)self.presentingViewController.view setInputAccessoryView];
}

@end
