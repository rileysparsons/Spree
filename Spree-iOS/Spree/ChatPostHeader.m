//
//  ChatPostHeader.m
//  Spree
//
//  Created by Riley Steele Parsons on 9/8/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "ChatPostHeader.h"
#import "SpreeUtility.h"

@implementation ChatPostHeader


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1. Load the .xib file .xib file must match classname
        NSString *className = NSStringFromClass([self class]);
        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        [self setNeedsUpdateConstraints];
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
        [self addSubview:_customView];
        
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
}

-(void)setupForPost:(SpreePost*)post {
    
    [self circularMaskForView:self.postImageView];
    if (post){
        [post fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
            if (((NSArray *)post[PF_POST_PHOTOARRAY]).count > 0){
                self.postImageView.file = post[PF_POST_PHOTOARRAY][0];
                [self.postImageView loadInBackground];
            }
            
            self.postTitleLabel.text = post[PF_POST_TITLE];
            self.priceLabel.text = [NSString stringWithFormat:@"$%@",[post[PF_POST_PRICE] stringValue]];
            
            [post[PF_POST_USER] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
                if  (!error){
                    NSString *title = [post[PF_POST_USER] objectForKey:@"displayName"] ? [SpreeUtility firstNameForDisplayName:[post[PF_POST_USER] objectForKey:@"displayName"]] : [post[PF_POST_USER] objectForKey:@"username"];
                    self.posterLabel.text =title;
                }
            }];
        }];
        
    }
}

-(void)circularMaskForView:(UIView *)view{
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) cornerRadius:MAX(view.frame.size.width, view.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor spreeDarkBlue].CGColor;
    circle.strokeColor = [UIColor spreeDarkBlue].CGColor;
    circle.lineWidth = 0;
    view.layer.mask=circle;
}


@end
