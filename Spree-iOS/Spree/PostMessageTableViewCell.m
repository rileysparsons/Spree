//
//  PostMessageTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/25/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostMessageTableViewCell.h"
#import "SpreeUtility.h"


@implementation PostMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setMessageButtonForPost:(SpreePost*)post{
    if (post[@"user"][@"displayName"]){
        [self.messageButton setTitle: [NSString stringWithFormat:@"Message %@", [SpreeUtility firstNameForDisplayName:post[@"user"][@"displayName"]]] forState:UIControlStateNormal];
    } else {
        [self.messageButton setTitle: @"Message Owner" forState:UIControlStateNormal];
    }
}

@end
