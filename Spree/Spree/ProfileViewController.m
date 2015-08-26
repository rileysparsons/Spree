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
    [self formatProfilePicture];
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

-(void)formatProfilePicture{
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.profileImage.frame.size.width, self.profileImage.frame.size.height) cornerRadius:MAX(self.profileImage.frame.size.width, self.profileImage.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor blackColor].CGColor;
    circle.strokeColor = [UIColor blackColor].CGColor;
    circle.lineWidth = 0;
    
    self.profileImage.layer.mask=circle;

}
@end
