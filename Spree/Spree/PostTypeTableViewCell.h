//
//  PostTypeTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/14/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCellAccessory.h"

@interface PostTypeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *detailImage;

@end
