//
//  MessagingTableViewCell.h
//  Spree
//
//  Created by Nick Young on 4/25/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKProfilePictureView.h>

@interface MessagingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *messageFlag;
@property (weak, nonatomic) IBOutlet PFImageView *postImageView;
@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;

@end
