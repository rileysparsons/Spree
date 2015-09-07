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
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.postImageView.frame.size.width, self.postImageView.frame.size.height) cornerRadius:MAX(self.postImageView.frame.size.width, self.postImageView.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor spreeOffWhite].CGColor;
    circle.strokeColor = [UIColor spreeOffWhite].CGColor;
    circle.lineWidth = 0;
    self.postImageView.layer.mask=circle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
