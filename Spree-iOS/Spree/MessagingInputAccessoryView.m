//
//  MessagingInputAccessoryView.m
//  Spree
//
//  Created by Riley Steele Parsons on 9/13/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "MessagingInputAccessoryView.h"
#import <Venmo-iOS-SDK/Venmo.h>

@interface MessagingInputAccessoryView ()

@property SpreePost *post;

@end

@implementation MessagingInputAccessoryView

- (id)initWithFrame:(CGRect)frame withPostType:(SpreePost *)post{
    self = [self initWithFrame:frame];
    NSLog(@"Sold %@", post[@"sold"]);
    self.post = post;
    [self.post.typePointer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if ([post[@"typePointer"][@"type"] isEqualToString: @"Tasks & Services"]){
            if (post[@"claimed"]){
                [self setupForUnclaimedPost];
            } else {
                [self setupForClaimedPost];
            }
        } else {
            if (!post.sold){
                [self setupForUnsoldPost];
            } else {
                [self setupForSoldPost];
            }
        }
    }];
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1. Load the .xib file .xib file must match classname
        NSString *className = NSStringFromClass([self class]);
        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        
        // 2. Set the bounds if not set by programmer (i.e. init called)
        if(CGRectIsEmpty(frame)) {
            self.bounds = _customView.bounds;
        }
        
        // 3. Add as a subview
        
        [self addSubview:_customView];
        [self stretchToSuperView:self.customView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        // 1. Load .xib file
        NSString *className = NSStringFromClass([self class]);
        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        
        // 2. Add as a subview
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_customView];
        [self stretchToSuperView:self.customView];
        
    }
    return self;
}


- (void) stretchToSuperView:(UIView*) view {
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSString *formatTemplate = @"%@:|[view]|";
    for (NSString * axis in @[@"H",@"V"]) {
        NSString * format = [NSString stringWithFormat:formatTemplate,axis];
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:bindings];
        [view.superview addConstraints:constraints];
    }
    [self layoutIfNeeded];
    NSLog(@"%@", self.customView.superview);
}

-(void)setupForUnclaimedPost{
    if (!_claimButton){
        _claimButton = [[UIButton alloc] initWithFrame:self.frame];
        _claimButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18];
        _claimButton.backgroundColor = [UIColor spreeDarkBlue];
        _claimButton.titleLabel.textColor = [UIColor spreeOffWhite];
        [_claimButton setTitle: @"Claim Post" forState:UIControlStateNormal];
        [self addSubview:_claimButton];
        [self stretchToSuperView:_claimButton];
    }
}

-(void)setupForClaimedPost{
    if (!_reviewButton){
        _reviewButton = [[UIButton alloc] initWithFrame:self.frame];
        _reviewButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18];
        _reviewButton.backgroundColor = [UIColor spreeDarkBlue];
        _reviewButton.titleLabel.textColor = [UIColor spreeOffWhite];
        [_reviewButton setTitle: @"Review User" forState:UIControlStateNormal];
        [self addSubview:_reviewButton];
        [self stretchToSuperView:_reviewButton];
    }
}

-(void)setupForSoldPost{
    if ([self.post.user.objectId isEqualToString:[PFUser currentUser].objectId]){
        PFQuery *query = [PFQuery queryWithClassName:@"RatingQueue"];
        [query whereKey:@"rateUser" equalTo:self.post[@"buyer"]];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query whereKey:@"post" equalTo:self.post];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            if (object){
                if (!_reviewButton){
                    _reviewButton = [[UIButton alloc] initWithFrame:self.frame];
                    _reviewButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18];
                    _reviewButton.backgroundColor = [UIColor spreeDarkBlue];
                    _reviewButton.titleLabel.textColor = [UIColor spreeOffWhite];
                    [_reviewButton setTitle: @"Review User" forState:UIControlStateNormal];
                    [self addSubview:_reviewButton];
                    [self stretchToSuperView:_reviewButton];
                }
            } else {
                [self setFrame:CGRectMake(0, 0, .1, .1)];
            }
        }];
    } else {
        [self setFrame:CGRectMake(0, 0, .1, .1)];
    }
}

-(void)setupForUnsoldPost{
    if (![[Venmo sharedInstance] isSessionValid]){
        if (!_authorizeVenmo){
            _authorizeVenmo = [[UIButton alloc] initWithFrame:self.frame];
            _authorizeVenmo.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18];
            _authorizeVenmo.backgroundColor = [UIColor spreeDarkBlue];
            _authorizeVenmo.titleLabel.textColor = [UIColor spreeOffWhite];
            [_authorizeVenmo setTitle: @"Authorize Venmo" forState:UIControlStateNormal];
            [self addSubview:_authorizeVenmo];
            [self stretchToSuperView:_authorizeVenmo];
        }
    } else {
        NSLog(@"%@", [PFUser currentUser].objectId);
        if (![self.post.user.objectId isEqualToString:[PFUser currentUser].objectId]){
            if (!_buyButton){
                _buyButton = [[UIButton alloc] initWithFrame:self.frame];
                _buyButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18];
                _buyButton.backgroundColor = [UIColor spreeDarkBlue];
                _buyButton.titleLabel.textColor = [UIColor spreeOffWhite];
                [_buyButton setTitle: @"Buy Post" forState:UIControlStateNormal];
                [_buyButton setTitle: @"Seller Has Not Authorized Venmo" forState:UIControlStateDisabled];
                [self addSubview:_buyButton];
                [self stretchToSuperView:_buyButton];
                 if (self.post.user[@"venmoId"]){
                     [_buyButton setEnabled:YES];
                 } else {
                     [_buyButton setEnabled:NO];
                 }
            }
        } else {
            [self setFrame:CGRectMake(0, 0, .1, .1)];
        }
    }
}

@end
