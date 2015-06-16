//
//  PostTitleTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 6/9/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostTitleTableViewCell : UITableViewCell

-(void)setTitleforPost:(SpreePost *)post;
-(void)setDescriptionTextViewForPost:(SpreePost *)post;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
