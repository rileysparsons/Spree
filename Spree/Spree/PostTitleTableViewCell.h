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
-(void)enableEditMode;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *editTitleButton;

@end
