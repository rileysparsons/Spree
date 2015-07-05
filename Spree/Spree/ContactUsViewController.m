//
//  ContactUsViewController.m
//  Spree
//
//  Created by Hamilton Coke on 7/4/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "ContactUsViewController.h"

@interface ContactUsViewController ()

@end

@implementation ContactUsViewController

- (IBAction)siteButton:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/spreemobile?fref=ts"]];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end