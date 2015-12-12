//
//  PostPaymentViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 9/14/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpreePost.h"

@protocol PostPaymentViewControllerDelegate;

@interface PostPaymentViewController : UIViewController

@property SpreePost *post;
@property id<PostPaymentViewControllerDelegate> delegate;

-(void)initializeWithPost:(SpreePost *)post;

@property (weak, nonatomic) IBOutlet UIView *amountContainer;
- (IBAction)sendButtonTouched:(id)sender;
- (IBAction)cancelButtonTouched:(id)sender;

@end


@protocol PostPaymentViewControllerDelegate <NSObject>

-(void)userOffered:(PFObject *)offer;

-(void)userFailedToCompletePurchase;

-(void)userPaidForService:(SpreePost *)service;

@end