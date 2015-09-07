//
//  PostShareView.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/26/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostShareView.h"

@implementation PostShareView

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
    NSLog(@"%@", self.customView);
}

- (UIImage *)captureView {
    //hide controls if needed
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}



@end
