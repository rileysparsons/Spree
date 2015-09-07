//
//  TextViewViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 2/9/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "TextViewViewController.h"

@interface TextViewViewController ()

@end

@implementation TextViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView.text = self.textDisplayed;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
