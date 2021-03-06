//
//  HomeHeaderView.h
//  Spree
//
//  Created by Riley Steele Parsons on 7/30/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <InfinitePagingView/InfinitePagingView.h>

IB_DESIGNABLE

@interface HomeHeaderView : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet InfinitePagingView *photoGallery;
@property HomeHeaderView *customView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *headerGestureRecognizer;


@end
