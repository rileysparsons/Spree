//
//  PostUserTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/10/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostUserTableViewCell.h"

@implementation PostUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUserLabelForPost:(SpreePost *)post{
    PFUser *user = post.user;
    [user fetchIfNeeded];
    self.userLabel.text = user.username;
}

@end
