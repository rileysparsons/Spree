//
//  ChatTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 4/10/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "ChatTableViewCell.h"

@interface ChatTableViewCell ()

@property IBOutlet UILabel *senderNameField;
@property IBOutlet UILabel *messageBodyField;
@property IBOutlet UIImageView *userImageView;
@property IBOutlet UILabel* dateField;

@end

@implementation ChatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
