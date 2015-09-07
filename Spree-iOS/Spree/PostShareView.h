//
//  PostShareView.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/26/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostShareViewDelegate;

@interface PostShareView : UIView

@property id<PostShareViewDelegate> delegate;
@property PostShareView *customView;
- (UIImage *)captureView;

@end

@protocol PostShareViewDelegate <NSObject>

@optional

-(void)viewInitializedForPost:(PostShareView *)view;

@end