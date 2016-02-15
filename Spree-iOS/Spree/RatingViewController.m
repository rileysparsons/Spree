//
//  RatingViewController.m
//  Spree
//
//  Created by Nick Young on 4/29/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "RatingViewController.h"
#import "SpreeUtility.h"
#import "ChatPostHeader.h"

@interface RatingViewController ()
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;
@property (weak, nonatomic) IBOutlet UILabel *rateUserLabel;
@property (weak, nonatomic) IBOutlet ChatPostHeader *postHeader;
@end

@implementation RatingViewController
@synthesize starRating = _starRating;
@synthesize rateUserLabel = _rateUserLabel;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Rate";
    
    if (self.user[@"displayName"]){
        _rateUserLabel.text = [NSString stringWithFormat:@"Please rate your recent transaction with %@", [SpreeUtility firstNameForDisplayName:self.user[@"displayName"]]];
    } else {
       _rateUserLabel.text = [NSString stringWithFormat:@"Please rate your recent transaction with %@", self.user[@"displayName"]];
    }

    self.starRating.backgroundColor  = [UIColor spreeOffWhite];
    // Setup control using iOS7 tint Color
    _starRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.maxRating = 5;
    _starRating.delegate = self;
    _starRating.editable = YES;
    _starRating.rating = 3;
    _starRating.displayMode = EDStarRatingDisplayFull;
    _starRating.tintColor = [UIColor spreeDarkBlue];
    
    
    [_postHeader setupForPost:(SpreePost *)self.post];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@ %@",self.user, self.ratingType);
    [_starRating setNeedsDisplay];
}

-(void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    // Have the seller rate the buyer
    
    PFQuery *query = [PFQuery queryWithClassName:@"Rating"];
    [query whereKey:@"user" equalTo:self.user];
    [query whereKey:@"type" equalTo:self.ratingType];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *ratingUser, NSError *error) {
        if (ratingUser) {
            int average = (int)[self.user objectForKey:@"average"];
            int averageSetSize = (int)[self.user objectForKey:@"averageSetSize"];

            average = ((average *averageSetSize) + (int)rating)/(averageSetSize + 1);

            ratingUser[@"average"] = [NSNumber numberWithInt:average];
            [ratingUser incrementKey:@"averageSetSize"];
            [ratingUser saveInBackground];
        } else {
            PFObject *ratingUser = [PFObject objectWithClassName:@"Rating"];
            ratingUser[@"user"] = self.user;
            ratingUser[@"type"] = self.ratingType;
            ratingUser[@"average"] = [NSNumber numberWithFloat:rating];
            ratingUser[@"averageSetSize"] = [NSNumber numberWithInt:1];
            [ratingUser saveInBackground];
        }
    }];

    if ([self.ratingType isEqualToString:@"seller"]) {
        // Have the buyer rate the seller
        PFObject *rateUserQueue = [PFObject objectWithClassName:@"RatingQueue"];
        rateUserQueue[@"user"] = self.user;
        rateUserQueue[@"post"] = self.post;
        rateUserQueue[@"rateUser"] = [PFUser currentUser];
        rateUserQueue[@"type"] = @"buyer";
        [rateUserQueue saveInBackground];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRated" object:self];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.delegate ratingViewControllerDelegateDidClose];
}

@end
