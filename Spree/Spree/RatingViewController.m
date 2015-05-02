//
//  RatingViewController.m
//  Spree
//
//  Created by Nick Young on 4/29/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "RatingViewController.h"

@interface RatingViewController ()
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;
@property (weak, nonatomic) IBOutlet UILabel *rateUserLabel;
@property (retain, nonatomic) UIBarButtonItem *cancelButton;
@end

@implementation RatingViewController
@synthesize starRating = _starRating;
@synthesize rateUserLabel = _rateUserLabel;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.cancelButton;

    _rateUserLabel.text = @"Rate User";

    self.starRating.backgroundColor  = [UIColor whiteColor];
    // Setup control using iOS7 tint Color
    _starRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.maxRating = 5;
    _starRating.delegate = self;
//    _starRating.horizontalMargin = 12.0;
    _starRating.editable=YES;
    _starRating.rating= 3;
    _starRating.displayMode=EDStarRatingDisplayFull;
    [_starRating  setNeedsDisplay];
    _starRating.tintColor = [UIColor spreeDarkBlue];
}

-(UIBarButtonItem *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModalViewAnimated)];
        [_cancelButton setTintColor:[UIColor whiteColor]];
    }
    return _cancelButton;
}

-(void)dismissModalViewAnimated
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


-(void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    NSLog(@"Rating: %.1f", rating);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserRated" object:self];
    [self dismissModalViewAnimated];
}

@end
