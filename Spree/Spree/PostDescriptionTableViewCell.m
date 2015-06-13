//
//  PostDescriptionTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/12/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostDescriptionTableViewCell.h"


@implementation PostDescriptionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDescriptionTextViewForPost:(SpreePost *)post{
    self.descriptionTextView.text = post.userDescription;
    self.descriptionTextView.scrollEnabled = NO;
    [self.descriptionTextView sizeToFit];
}

@end
