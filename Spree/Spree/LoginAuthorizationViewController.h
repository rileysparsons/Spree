//
//  LoginAuthorizationViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginAuthorizationViewControllerDelegate;

@interface LoginAuthorizationViewController : UIViewController

@property PFUser *user;
@property id<LoginAuthorizationViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
- (IBAction)authorizeButtonTapped:(id)sender;
- (IBAction)optOutButtonTapped:(id)sender;


@end

@protocol LoginAuthorizationViewControllerDelegate <NSObject>


///--------------------------------------
/// @name Responding to Actions
///--------------------------------------

- (void)logInAuthorizationViewController:(LoginAuthorizationViewController *)authorizationController didAuthorizeFacebookForUser:(PFUser *)user;


- (void)logInAuthorizationViewController:(LoginAuthorizationViewController *)authorizationController
               didFailToAuthorizeFacebookForUser:(PFUser *)user;

- (void)logInAuthorizationViewControllerWentBackwards:(LoginAuthorizationViewController *)authorizationController;

- (void)logInAuthorizationViewController:(LoginAuthorizationViewController *)authorizationController userDidOptOut:(PFUser *)user;




@end
