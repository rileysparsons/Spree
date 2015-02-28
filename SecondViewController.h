//
//  SecondViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SecondViewController;

@protocol SecondViewControllerDelegate <NSObject>

- (void)secondViewControllerDidLogout:(SecondViewController *)controller;

@end

@interface SecondViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) id<SecondViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;


@end

 