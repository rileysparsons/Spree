//
//  BasicInfoTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/19/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "BasicInfoTableViewCell.h"

@implementation BasicInfoTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.editButton.hidden = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
    // Configure the view for the selected state
}

-(void)enableEditMode{
    self.editButton.hidden = NO;
}



@end
