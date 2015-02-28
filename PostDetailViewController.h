//
//  PostDetailViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SpreePost.h"

@interface PostDetailViewController : UIViewController <UIAlertViewDelegate, UIScrollViewDelegate>

@property SpreePost *detailPost;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *postScrollView;
@property (weak, nonatomic) UIImage *postImage;

@end
