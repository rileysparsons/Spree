//
//  SelectCampusTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/4/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SelectCampusTableViewCell.h"
#import <MSCellAccessory/MSCellAccessory.h>

@implementation SelectCampusTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeDarkBlue] highlightedColor:[UIColor spreeDarkYellow]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
