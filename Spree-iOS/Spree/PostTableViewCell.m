//
//  PostTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/19/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "PostTableViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "SpreePost.h"

@interface PostTableViewCell ()

@property (weak, nonatomic) IBOutlet PFImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeIcon;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *imageBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderIconView;

@end

@implementation PostTableViewCell

- (void)awakeFromNib {
    // Initialization code

    [self circularMaskForView:self.postImageView];
    [self circularMaskForView:self.imageBackgroundView];
}

-(void)bindViewModel:(id)viewModel{
    
    SpreePost* post = (SpreePost*)viewModel;
    self.postTitleLabel.text = post.title;
    
    if (post.price == 0 || [post.price  isEqual: @(0)]){
        self.priceLabel.text = @"Free";
    } else {
        int priceFloat = [post.price intValue];
        NSString *price = [NSString stringWithFormat:@"$%d", priceFloat];
        self.priceLabel.text = price;
    }
    
    NSDate *dateCreatedGMT = [post createdAt];
    NSTimeInterval timeSince = dateCreatedGMT.timeIntervalSinceNow;
    double timeSinceInDays = timeSince/60/60/24*(-1);
    if (timeSinceInDays > 1){
        double roundedValue = round(timeSinceInDays);
        int roundedInteger = (int)roundedValue;
        NSNumber *numberSince = [NSNumber numberWithInt:roundedInteger];
        NSString *timeSincePost = [numberSince stringValue];
        NSString *timeWithUnits = [NSString stringWithFormat:(@"%@ days ago"), timeSincePost];
        self.postTimeLabel.text = timeWithUnits;
    } else {
        double timeSinceInHours = timeSinceInDays*24;
        double timeSinceInMinutes = timeSinceInHours*60;
        if (timeSinceInHours > 1){
            double timeSinceInHoursRounded = round(timeSinceInHours);
            int roundedInteger = (int)timeSinceInHoursRounded;
            NSNumber *numberSince = [NSNumber numberWithInt:roundedInteger];
            NSString *timeSincePost = [numberSince stringValue];
            NSString *timeWithUnits = [NSString stringWithFormat:(@"%@ hours ago"), timeSincePost];
            self.postTimeLabel.text = timeWithUnits;
        } else if (timeSinceInMinutes > 1){
            int roundedInteger = (int)timeSinceInMinutes;
            NSNumber *numberSince = [NSNumber numberWithInt:roundedInteger];
            NSString *timeSincePost = [numberSince stringValue];
            NSString *timeWithUnits = [NSString stringWithFormat:(@"%@ minutes ago"), timeSincePost];
            self.postTimeLabel.text = timeWithUnits;
        } else {
            NSString *message = @"Just now";
            self.postTimeLabel.text = message;
        }
    }
    
    self.descriptionLabel.text = [NSString stringWithFormat:@"\u201C%@\u201D", post.userDescription];


    if (post.photoArray.count != 0){
        PFFile *imageFile = (PFFile *)[post.photoArray objectAtIndex:0];
        self.postImageView.file = imageFile;
        [self.postImageView loadInBackground];
    } else {
        self.imageBackgroundView.backgroundColor = [UIColor spreeOffBlack];
        [post.typePointer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
            if ([post.typePointer[@"type"] isEqualToString: @"Tasks & Services"]){
                self.placeholderIconView.image = [UIImage imageNamed:@"tasksAndServicesThumbnail"];
            }
        }];
    }


    
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
    circle.fillColor = [UIColor spreeOffWhite].CGColor;
    circle.strokeColor = [UIColor spreeOffWhite].CGColor;
    circle.lineWidth = 0;
    view.layer.mask=circle;
}



@end
