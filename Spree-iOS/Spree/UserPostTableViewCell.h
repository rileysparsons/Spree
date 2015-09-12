//
//  UserPostTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 9/10/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostTableViewCell.h"

@interface UserPostTableViewCell : PostTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *shadeView;

@end
