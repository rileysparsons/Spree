//
//  AuthorizeVenmoViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 9/14/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AuthorizeVenmoViewControllerDelegate;

@interface AuthorizeVenmoViewController : UIViewController

@property id<AuthorizeVenmoViewControllerDelegate> delegate;

- (IBAction)linkVenmoButtonTouched:(id)sender;
- (IBAction)notNowButtonTouched:(id)sender;

@end

@protocol AuthorizeVenmoViewControllerDelegate <NSObject>

-(void)userDidAuthorizeVenmo;

-(void)userDidNotAuthorizeVenmo;

@end
