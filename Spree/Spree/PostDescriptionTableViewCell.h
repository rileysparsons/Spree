//
//  PostDescriptionTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 6/12/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpreePost.h"

@interface PostDescriptionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

-(void)setDescriptionTextViewForPost:(SpreePost *)post;

@end

