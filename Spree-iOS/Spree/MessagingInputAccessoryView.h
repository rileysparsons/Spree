//
//  MessagingInputAccessoryView.h
//  Spree
//
//  Created by Riley Steele Parsons on 9/13/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostTableViewCell.h"
#import "SpreePost.h"

@interface MessagingInputAccessoryView : PostTableViewCell

@property MessagingInputAccessoryView *customView;
@property UIButton *claimButton;
@property UIButton *reviewButton;
@property UIButton *buyButton;
@property UIButton *authorizeVenmo;

- (id)initWithFrame:(CGRect)frame withPostType:(SpreePost *)post;

@end
