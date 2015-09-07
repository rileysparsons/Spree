//
//  PhotoGalleryTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/10/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PhotoGalleryTableViewCell.h"
#import "converter.h"

@implementation PhotoGalleryTableViewCell 


- (void)setFrame:(CGRect)frame {
    if(frame.size.width != self.bounds.size.width) {
        [super setFrame:frame];
        self.contentView.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.contentView layoutIfNeeded];
    }
    else {
        [super setFrame:frame];
    }
}


- (void)awakeFromNib {
    // Initialization code
    self.photoGallery.delegate = self;
    self.counterLabel.text = [NSString stringWithFormat:@"1/%lu", self.pageViews.count];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bottomGradient.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor spreeOffBlack] CGColor], nil];
    [self.bottomGradient.layer insertSublayer:gradient atIndex:0];
    [self.editButton setHidden:YES];
    [self.editPriceButton setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPhotoGalleryForImages:(NSArray*)images{
    [self layoutSubviews];
    CGSize pagesScrollViewSize = self.photoGallery.frame.size;
    self.pageImages = images;
    self.photoGallery.contentSize = CGSizeMake(self.frame.size.width * self.pageImages.count, pagesScrollViewSize.height);
    NSLog(@"IMAGES FROM CELL %@ and width %f, with screen %f, and count %lu", images, pagesScrollViewSize.width, self.frame.size.width, (unsigned long)images.count);
    [self setupGallery];
    self.photoGallery.contentOffset = CGPointZero;
//    if (images.count == 1){
//        self.counterLabel.hidden = YES;
//    } else {
//        self.counterLabel.hidden = NO;
//    }
}

-(void)setDateLabelForPost:(SpreePost *)post{
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:post.createdAt];
    self.dateLabel.text = TimeElapsed(seconds);
}

-(void)setupPriceLabelForPost:(SpreePost *)post{
    NSString *priceString = [NSString stringWithFormat:@"$%@", post.price];
    self.priceLabel.text = priceString;
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.priceView.frame.size.width, self.priceView.frame.size.height) cornerRadius:MAX(self.priceView.frame.size.width, self.priceView.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor spreeOffWhite].CGColor;
    circle.strokeColor = [UIColor spreeOffWhite].CGColor;
    circle.lineWidth = 0;
    self.priceView.layer.mask=circle;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.photoGallery){
        // Load the pages that are now on screen
        [self loadVisiblePages];
    }
}

# pragma mark - Photo Gallery Scroll View
- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // 1
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        // 2
        CGRect frame = self.photoGallery.bounds;
        frame.origin.x = frame.size.width * page;
        NSLog(@"%f", frame.origin.x);
        frame.origin.y = 0.0f;
        
          // 3
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:page]];
        newPageView.contentMode = UIViewContentModeScaleAspectFill;
        newPageView.frame = frame;
        [self.photoGallery addSubview:newPageView];
        // 4
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.photoGallery.frame.size.width;
    NSInteger page = (NSInteger)floor((self.photoGallery.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control (Removed)
    NSString *currentPage = [@(page+1) stringValue];
    NSString *totalPages = [@(self.pageViews.count) stringValue];
    self.counterLabel.text = [NSString stringWithFormat:@"%@/%@", currentPage, totalPages];
    
    // Work out which pages you want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    
    // Load pages in our range
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    
    // Purge anything after the last page
    for (NSInteger i=lastPage+1; i<self.pageImages.count; i++) {
        [self purgePage:i];
    }
}

- (void)setupGallery {
    NSInteger pageCount = self.pageImages.count;
    
    self.photoGalleryControl.currentPage = 0;
    self.photoGalleryControl.numberOfPages = pageCount;
    
    NSString *currentPage = [@(1) stringValue];
    NSString *totalPages = [@(pageCount) stringValue];
    self.counterLabel.text = [NSString stringWithFormat:@"%@/%@", currentPage, totalPages];
    
    // 3
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
    CGSize pagesScrollViewSize = self.photoGallery.frame.size;
    self.photoGallery.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageImages.count, pagesScrollViewSize.height);
    [self loadVisiblePages];
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(void)enableEditMode{
    self.editButton.hidden = NO;
    self.editPriceButton.hidden = NO;
}


@end
