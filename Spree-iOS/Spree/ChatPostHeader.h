//
//  ChatPostHeader.h
//  Spree
//
//  Created by Riley Steele Parsons on 9/8/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpreePost.h"

@interface ChatPostHeader : UIView

@property ChatPostHeader *customView;


@property (weak, nonatomic) IBOutlet PFImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *posterLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

-(void)setupForPost:(SpreePost*)post;

@end
