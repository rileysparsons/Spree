//
//  PostTitleTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/9/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//
#import "SpreePost.h"
#import "PostTitleTableViewCell.h"

@implementation PostTitleTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.editTitleButton.hidden = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTitleforPost:(SpreePost *)post{
    self.titleLabel.text = post.title;
    [self.titleLabel sizeToFit];
    self.titleLabel.preferredMaxLayoutWidth = self.bounds.size.width - 40;
}

-(void)enableEditMode{
    self.editTitleButton.hidden = NO;
}

@end
