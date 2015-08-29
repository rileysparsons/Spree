//
//  PostUserTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 6/10/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpreePost.h"
#import "EDStarRating.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface PostUserTableViewCell : UITableViewCell

-(void)setUserLabelForPost:(SpreePost *)post;

@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *userImageView;

@end
