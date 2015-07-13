//
//  PhotoSelectTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/12/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PhotoSelectTableViewCell.h"

@implementation PhotoSelectTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.deleteButton.enabled = NO;
    self.deleteButton.hidden = YES;
    self.addPhotoButton.enabled = YES;
    self.addPhotoButton.hidden = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithImage:(UIImage *)image{
    if (image){
        self.cellImageView.image = image;
        self.deleteButton.enabled = YES;
        self.deleteButton.hidden = NO;
        self.addPhotoButton.enabled = NO;
        self.addPhotoButton.hidden = YES;
    } else {
        [self emptyCell];
    }
}

-(void)emptyCell {
    self.deleteButton.enabled = NO;
    self.deleteButton.hidden = YES;
    self.addPhotoButton.enabled = YES;
    self.addPhotoButton.hidden = NO;
}

@end
