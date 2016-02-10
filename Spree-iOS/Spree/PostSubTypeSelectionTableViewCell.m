//
//  PostSubTypeSelectionTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 1/21/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "PostSubTypeSelectionTableViewCell.h"

@implementation PostSubTypeSelectionTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)bindViewModel:(id)viewModel{
    
    PFObject* type = (PFObject*)viewModel;
    self.titleLabel.text = type[@"subtype"];
    
}

@end
