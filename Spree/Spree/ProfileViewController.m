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
    NSLog(@"%@", self.detailUser);
    self.usernameLabel.text = self.detailUser.username;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM YYYY"];
    self.sinceLabel.text = [NSString stringWithFormat:@"On Spree since %@",[formatter stringFromDate:self.detailUser.createdAt]];
    PFQuery *ratingQuery = [PFQuery queryWithClassName:@"Rating"];
    [ratingQuery whereKey:@"user" equalTo:self.detailUser];
    [ratingQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (object){
            if ([object[@"averageSetSize"] integerValue] == 1){
                self.reviewLabel.text = [NSString stringWithFormat:@"%.1f (%@ rating)", [object[@"average"]floatValue], object[@"averageSetSize"]];
            } else {
                self.reviewLabel.text = [NSString stringWithFormat:@"%.1f (%@ ratings)", [object[@"average"]floatValue], object[@"averageSetSize"]];
            }
        } else {
            self.reviewLabel.text = @"No ratings yet";
        }
    }];
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
