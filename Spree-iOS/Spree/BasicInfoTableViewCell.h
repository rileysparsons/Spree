//
//  BasicInfoTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 7/19/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicInfoTableViewCell : UITableViewCell


-(void)enableEditMode;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;
@property (weak, nonatomic) IBOutlet UILabel *fieldTitleLabel;

@end
