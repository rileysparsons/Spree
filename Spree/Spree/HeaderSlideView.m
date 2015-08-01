//
//  HeaderSlideView.m
//  
//
//  Created by Riley Steele Parsons on 7/31/15.
//
//

#import "HeaderSlideView.h"

@implementation HeaderSlideView

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

-(void)setTitleWithString:(NSString *)title{
    self.slideTitle.text = title;
}

-(void)setBackgroundImageWithImage:(UIImage *)image{
    self.backgroundImage.image = image;
}

@end
