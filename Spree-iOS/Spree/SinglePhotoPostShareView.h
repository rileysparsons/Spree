//
//  FacebookShareView.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/25/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpreePost.h"
#import "PostShareView.h"


@interface SinglePhotoPostShareView : PostShareView

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UILabel *postAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *postPriceBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *postPriceLabel;


-(void)initWithPost:(SpreePost *)post;

@end


