//
//  PhotoDisplayTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/17/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PhotoDisplayTableViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation PhotoDisplayTableViewCell

-(void)bindViewModel:(id)viewModel{
    [self placeImage:[UIImage imageWithData:viewModel]];
}

- (void)awakeFromNib {
    // Initialization code    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)placeImage:(UIImage *)image{
    if (image){
        float aspect = image.size.width/image.size.height;
        float height = (self.frame.size.width-16)*(1/aspect);
        NSLog(@"%f", height);
        self.heightLayoutConstraint.constant = height;
        self.cellImageView.image = image;
    }
}



@end
