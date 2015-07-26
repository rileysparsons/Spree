//
//  PhotoDisplayTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 7/17/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDisplayTableViewCell : UITableViewCell

-(void)initWithImage:(UIImage *)image;

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayoutConstraint;

@end
