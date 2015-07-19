//
//  PhotoGalleryTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 6/10/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpreePost.h"

@interface PhotoGalleryTableViewCell : UITableViewCell <UIScrollViewDelegate>

-(void)enableEditMode;
- (void)loadVisiblePages;
- (void)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;
- (void)setPhotoGalleryForImages:(NSArray *)images;
-(void)setDateLabelForPost:(SpreePost *)post;

@property (nonatomic, strong) NSArray *pageImages;
@property (nonatomic, strong) NSMutableArray *pageViews;
@property (weak, nonatomic) IBOutlet UIScrollView *photoGallery;
@property UIPageControl *photoGalleryControl;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomGradient;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end
