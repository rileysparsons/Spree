//
//  PhotoSelectTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 7/12/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoSelectTableViewCell : UITableViewCell

-(void)initWithImage:(UIImage *)image;
-(void)emptyCell;

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;

@end
