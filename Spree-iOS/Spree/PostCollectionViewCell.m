//
//  PostCollectionViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 3/6/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "PostCollectionViewCell.h"
#import "SpreePost.h"


@interface PostCollectionViewCell (){
    UIColor *backgroundColorFromPhoto;
}

@property (weak, nonatomic) IBOutlet PFImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *postSubtitleView;
@property (weak, nonatomic) IBOutlet UIView *priceBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation PostCollectionViewCell

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
    
    /*
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
    */
    
    
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
     
    self.postSubtitleView.text = [NSString stringWithFormat:@"\u201C%@\u201D", post.userDescription];
    self.backgroundColor = backgroundColorFromPhoto = [UIColor clearColor];
    self.postImageView.image = nil;
    
    if (post.photoArray.count != 0){
        PFFile *imageFile = (PFFile *)[post.photoArray objectAtIndex:0];
        self.postImageView.file = imageFile;
        [self.postImageView loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
            self.backgroundColor = backgroundColorFromPhoto = [[self averageColorFromImage:image] colorWithAlphaComponent:0.20];
        }];
    } else {
        self.postImageView.image = nil;
        self.postImageView.backgroundColor = [UIColor spreeOffBlack];
    }

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutIfNeeded];
    self.priceBackgroundView.layer.cornerRadius = self.priceBackgroundView.frame.size.width / 2;
}

- (void)awakeFromNib {
    // Initialization code
}

-(void)setSelected:(BOOL)selected{
    if (selected){
        self.backgroundColor = [[UIColor spreeOffBlack] colorWithAlphaComponent:0.7f];
    } else {
        self.backgroundColor = backgroundColorFromPhoto;
    }
}

- (UIColor *)averageColorFromImage:(UIImage *)image{
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

@end
