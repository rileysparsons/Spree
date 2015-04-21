//
//  PostTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/19/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "PostTableViewCell.h"

@implementation PostTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.postImageView.clipsToBounds = YES;
    self.postImageView.autoresizingMask = UIViewAutoresizingNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
