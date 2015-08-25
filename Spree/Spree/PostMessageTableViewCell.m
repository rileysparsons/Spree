//
//  PostMessageTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/25/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostMessageTableViewCell.h"

@implementation PostMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setMessageButtonForPost:(SpreePost*)post{
    [post.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
        NSString *messageTitle = [NSString stringWithFormat:@"Message %@", object[@"username"]];
        self.messageButton.titleLabel.text = messageTitle;
    }];
}

@end
