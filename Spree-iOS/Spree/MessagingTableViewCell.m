//
//  MessagingTableViewCell.m
//  Spree
//
//  Created by Nick Young on 4/25/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "MessagingTableViewCell.h"

@implementation MessagingTableViewCell

- (void)awakeFromNib {
    
    [self circularMaskForView:self.userImageView];
    [self circularMaskForView:self.postImageView];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)circularMaskForView:(UIView *)view{
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) cornerRadius:MAX(view.frame.size.width, view.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor spreeDarkBlue].CGColor;
    circle.strokeColor = [UIColor spreeDarkBlue].CGColor;
    circle.lineWidth = 0;
    view.layer.mask=circle;
}

@end
