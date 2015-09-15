//
//  RatingViewController.h
//  Spree
//
//  Created by Nick Young on 4/29/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "EDStarRating.h"

@protocol RatingViewControllerDelegate;

@interface RatingViewController : UIViewController <EDStarRatingProtocol>
@property (strong, nonatomic) PFObject *user;
@property PFObject *post;
@property (weak, nonatomic) NSString *ratingType;
@property id<RatingViewControllerDelegate> delegate;

@end

@protocol RatingViewControllerDelegate <NSObject>

-(void)ratingViewControllerDelegateDidClose;

@end
