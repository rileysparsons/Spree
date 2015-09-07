//
//  ProfileViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 6/15/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
@property PFUser *detailUser;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sinceLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;

@end
