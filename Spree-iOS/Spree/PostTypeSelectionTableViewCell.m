//
//  PostTypeSelectionTableViewCell.m
//  
//
//  Created by Riley Steele Parsons on 6/28/15.
//
//

#import "PostTypeSelectionTableViewCell.h"
#import "AppConstant.h"


@implementation PostTypeSelectionTableViewCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)awakeFromNib{
    self.iconBackground.backgroundColor = [UIColor spreeDarkBlue];
    [self circularMaskForView:self.iconBackground];
}

-(void)initWithPostType:(PFObject *)type{
    
    self.typeLabel.text = type[@"type"];
    
    if ([type[@"type"] isEqualToString:POST_TYPE_ACCESSORIES]){
        [self.typeImage setImage:[UIImage imageNamed:@"accessoriesThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_CLOTHING]){
        [self.typeImage setImage:[UIImage imageNamed:@"clothingThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_ELECTRONICS]){
        [self.typeImage setImage:[UIImage imageNamed:@"electronicsThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_FURNITURE]){
        [self.typeImage setImage:[UIImage imageNamed:@"furnitureThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_KITCHEN]){
        [self.typeImage setImage:[UIImage imageNamed:@"kitchenThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_OUTDOORS]){
        [self.typeImage setImage:[UIImage imageNamed:@"outdoorsThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_SPORTS]){
        [self.typeImage setImage:[UIImage imageNamed:@"sportsThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_TASKSANDSERVICES]){
        [self.typeImage setImage:[UIImage imageNamed:@"tasksAndServicesThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_TICKETS]){
        [self.typeImage setImage:[UIImage imageNamed:@"ticketThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_WHEELS]){
        [self.typeImage setImage:[UIImage imageNamed:@"wheelsThumbnail"]];
    } else if ([type[@"type"] isEqualToString:POST_TYPE_BOOKS]){
        [self.typeImage setImage:[UIImage imageNamed:@"booksThumbnail"]];
    }
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
