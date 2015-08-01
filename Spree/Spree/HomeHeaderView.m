//
//  HomeHeaderView.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/30/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "HomeHeaderView.h"
#import "HeaderSlideView.h"

@implementation HomeHeaderView

- (void)setFrame:(CGRect)frame {
    if(frame.size.width != self.bounds.size.width) {
        [super setFrame:frame];
        self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self layoutIfNeeded];
    }
    else {
        [super setFrame:frame];
    }
}


- (void)awakeFromNib {
    // Initialization code
    self.photoGallery.delegate = self;
}

@end
