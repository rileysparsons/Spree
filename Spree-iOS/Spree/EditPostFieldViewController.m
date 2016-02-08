//
//  EditPostFieldViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/19/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "EditPostFieldViewController.h"
#import "PreviewPostViewController.h"

@interface EditPostFieldViewController ()

@end

@implementation EditPostFieldViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarButtons];
    // Do any additional setup after loading the view.
    [[self.viewModel.nextCommand.executionSignals switchToLatest] subscribeNext:^(id x) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)navigationBarButtons{
    self.nextButton= [[UIButton alloc] initWithFrame:CGRectZero];
    self.nextButton.tag = 2;
    self.nextButton.backgroundColor = [UIColor clearColor];
    [self.nextButton setTitle:@"Update" forState:UIControlStateNormal];
    [self.nextButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
    [self.nextButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateNormal];
    [self.nextButton sizeToFit];
    self.nextButton.rac_command = self.viewModel.nextCommand;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
}

@end
