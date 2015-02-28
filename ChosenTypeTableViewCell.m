//
//  ChosenTypeTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/15/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "ChosenTypeTableViewCell.h"

@implementation ChosenTypeTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _typeImage.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
