//
//  PostUserTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/10/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <MSCellAccessory/MSCellAccessory.h>
#import "PostUserTableViewCell.h"

@implementation PostUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeDarkBlue]];
    self.userImageView.profileID = [PFUser currentUser][@"fbId"];
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.userImageView.frame.size.width, self.userImageView.frame.size.height) cornerRadius:MAX(self.userImageView.frame.size.width, self.userImageView.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor blackColor].CGColor;
    circle.strokeColor = [UIColor blackColor].CGColor;
    circle.lineWidth = 0;
    
    self.userImageView.layer.mask=circle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUserLabelForPost:(SpreePost *)post{
    PFUser *user = post.user;
    NSLog(@"Cell user %@", user);
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.userLabel.text = [(PFUser *)object username];
        [self setRatingForUser:(PFUser *)object];
    }];
}

-(void)setRatingForUser:(PFUser*)user{
    PFQuery *ratingQuery = [PFQuery queryWithClassName:@"Rating"];
    [ratingQuery whereKey:@"user" equalTo:user];
    [ratingQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (object){
            if ([object[@"averageSetSize"] integerValue] == 1){
                self.ratingLabel.text = [NSString stringWithFormat:@"%.1f (%@ rating)", [object[@"average"]floatValue], object[@"averageSetSize"]];
            } else {
                self.ratingLabel.text = [NSString stringWithFormat:@"%.1f (%@ ratings)", [object[@"average"]floatValue], object[@"averageSetSize"]];
            }
        } else {
            self.ratingLabel.text = @"No ratings yet";
        }
    }];
}


@end
