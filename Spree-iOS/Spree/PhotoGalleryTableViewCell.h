//
//  PhotoGalleryTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 6/10/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEReactiveView.h"
#import "SpreePost.h"

@interface PhotoGalleryTableViewCell : UITableViewCell <UIScrollViewDelegate, CEReactiveView>

-(void)enableEditMode;
- (void)loadVisiblePages;
- (void)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;
-(void)setDateLabelForPost:(SpreePost *)post;
-(void)setupPriceLabelForPost:(SpreePost *)post;

@property (weak, nonatomic) IBOutlet UIView *priceView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editPhotosButtonHeight;
@property (weak, nonatomic) IBOutlet UIButton *editPriceButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editPricebuttonHeight;

@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (weak, nonatomic) IBOutlet UIScrollView *photoGallery;
@property UIPageControl *photoGalleryControl;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomGradient;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end
