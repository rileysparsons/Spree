//
//  PhotoSelectTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 7/12/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoSelectTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidthLayoutContraint;
@property (weak, nonatomic) IBOutlet UIButton *pickPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;


@end
