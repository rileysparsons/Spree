//
//  LoginCampusTableViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginCampusTableViewControllerDelegate;

@interface LoginCampusTableViewController : PFQueryTableViewController
@property PFUser *user;
@property id<LoginCampusTableViewControllerDelegate> delegate;

@end


@protocol LoginCampusTableViewControllerDelegate <NSObject>

@optional

-(void)loginCampusTableViewController:(LoginCampusTableViewController *)loginCampusTableViewController didSelectCampus:(PFObject *)campus;

@end