//
//  PostMessageTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/25/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpreePost.h"

@interface PostMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *messageButton;


-(void)setMessageButtonForPost:(SpreePost*)post;

@end
