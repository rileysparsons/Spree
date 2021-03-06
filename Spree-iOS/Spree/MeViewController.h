//
//  SecondViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <RCSLabeledIconButton/RCSLabeledIconButton.h>
#import "Branch/Branch.h"

@interface MeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;
@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *networkLabel;

- (IBAction)settingsButtonTouched:(id)sender;


@end


 