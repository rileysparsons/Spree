//
//  PostTypeTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/14/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "PostTypeTableViewCell.h"

@implementation PostTypeTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)awakeFromNib{
    self.iconBackground.backgroundColor = [UIColor spreeDarkBlue];
    [self circularMaskForView:self.iconBackground];
}

-(void)initWithPostType:(PFObject *)type{
    if ([type[@"type"] isEqualToString:POST_TYPE_ACCESSORIES]){
        [self.detailImage setImage:[UIImage imageNamed:@"accessoriesThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_CLOTHING]){
        [self.detailImage setImage:[UIImage imageNamed:@"clothingThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_ELECTRONICS]){
        [self.detailImage setImage:[UIImage imageNamed:@"electronicsThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_FURNITURE]){
        [self.detailImage setImage:[UIImage imageNamed:@"furnitureThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_KITCHEN]){
        [self.detailImage setImage:[UIImage imageNamed:@"kitchenThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_OUTDOORS]){
        [self.detailImage setImage:[UIImage imageNamed:@"outdoorsThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_SPORTS]){
        [self.detailImage setImage:[UIImage imageNamed:@"sportsThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_TASKSANDSERVICES]){
        [self.detailImage setImage:[UIImage imageNamed:@"tasksAndServicesThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_TICKETS]){
        [self.detailImage setImage:[UIImage imageNamed:@"ticketThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_WHEELS]){
        [self.detailImage setImage:[UIImage imageNamed:@"wheelsThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_BOOKS]){
        [self.detailImage setImage:[UIImage imageNamed:@"booksThumbnail"]];
    }
    
    [self setCountLabelForType:type];

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

-(void)setCountLabelForType:(PFObject *)type{
//    PFQuery *countQuery = [PFQuery queryWithClassName:@"]
//    [postQuery whereKey:@"type" equalTo:[_postTypeArray objectAtIndex:indexPath.row]];
//    [postQuery whereKey:@"expired" equalTo:[NSNumber numberWithBool:NO]];
//    [postQuery whereKey:@"sold" equalTo:[NSNumber numberWithBool:NO]];
//    [postQuery whereKey:@"network" equalTo:[[PFUser currentUser] objectForKey:@"network"]];
//    
//    [postQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//        cell.numberLabel.text = [NSString stringWithFormat:@"0 Posts"];
//        if (number) {
//            [self.refreshControl endRefreshing];
//            cell.numberLabel.text = [NSString stringWithFormat:@"%@ Posts", [@(number)stringValue]];
//            _pastPostNumber = number;
//        }
//    }];
    if ([(NSNumber *)type[@"count"] integerValue] == 0){
       self.numberLabel.text = @"No posts";
    } else if ([(NSNumber *)type[@"count"] integerValue] == 1){
        self.numberLabel.text = [NSString stringWithFormat:@"%@ total post", [(NSNumber *)type[@"count"] stringValue]];
    } else {
         self.numberLabel.text = [NSString stringWithFormat:@"%@ total posts", [(NSNumber *)type[@"count"] stringValue]];
    }

}

@end
