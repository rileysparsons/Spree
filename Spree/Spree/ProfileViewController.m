//
//  ProfileViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/15/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupForUser];
}

-(void)setupForUser{
    self.usernameLabel.text = self.detailUser.username;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM YYYY"];
    self.sinceLabel.text = [NSString stringWithFormat:@"On Spree since %@",[formatter stringFromDate:self.detailUser.createdAt]];
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
