//
//  DoublePhotoFacebookShareView.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/26/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "DoublePhotoPostShareView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@implementation DoublePhotoPostShareView

-(void)initWithPost:(SpreePost *)post{
    [self circularImage];
    NSMutableArray *tempPhotoArray = [[NSMutableArray alloc] init];
    self.postDescriptionLabel.text = post.userDescription;
    self.postPriceLabel.text = [NSString stringWithFormat:@"$%@", [post.price stringValue]];
    self.postTitleLabel.text = [NSString stringWithFormat:@"A %@", post.title];
    
    
    for (PFFile *imageFile in post.photoArray){
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                [tempPhotoArray addObject:image];
                [self setupImageViewsWithImageArray:tempPhotoArray];
                // image can now be set on a UIImageView
                [self initializationComplete];
            }
        }];
    }

    
    
    [post.user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (object[@"fbId"]){
            NSString *graphPath = [NSString stringWithFormat:@"%@?fields=first_name", object[@"fbId"]];
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:nil];
            //                         Send request to Facebook
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSString *authorString = [NSString stringWithFormat:@"%@ IS SELLING", [result[@"first_name"] uppercaseString]];
                    self.postAuthorLabel.text = authorString;
                    [self initializationComplete];
                } else {
                    NSLog(@"%@",error);
                }
            }];
        } else {
            NSString *authorString = [NSString stringWithFormat:@"%@ IS SELLING", [object[@"displayName"] uppercaseString]];
            self.postAuthorLabel.text = authorString;
            [self initializationComplete];
        }
    }];
    [self initializationComplete];
}

-(void)setupImageViewsWithImageArray:(NSArray *)array{
    self.imageView1.image = [array objectAtIndex:0];
    self.imageView2.image = [array objectAtIndex:1];
}


-(void)initializationComplete{
    if (self.postAuthorLabel.text.length > 1 && self.imageView2.image && self.imageView1.image){
        [self.delegate viewInitializedForPost:self];
    }
}

-(void)circularImage{
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.postPriceBackgroundView.frame.size.width, self.postPriceBackgroundView.frame.size.height) cornerRadius:MAX(self.postPriceBackgroundView.frame.size.width, self.postPriceBackgroundView.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor spreeOffWhite].CGColor;
    circle.strokeColor = [UIColor spreeOffWhite].CGColor;
    circle.lineWidth = 0;
    self.postPriceBackgroundView.layer.mask=circle;
}

@end
