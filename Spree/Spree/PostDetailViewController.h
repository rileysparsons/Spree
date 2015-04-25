//
//  PostDetailViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "SpreePost.h"

@interface PostDetailViewController : UIViewController <UIAlertViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate>

@property SpreePost *detailPost;
@property PFUser *poster;

@property (weak, nonatomic) IBOutlet UILabel *postDateUserLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *postScrollView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIView *detailBarView;
@property (weak, nonatomic) IBOutlet UILabel *bookForClassLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateForTicketLabel;
@property (weak, nonatomic) UIImage *postImage;
@property (weak, nonatomic) IBOutlet UIView *posterInfoView;
// Admin Bar Properties
@property (weak, nonatomic) IBOutlet UIView *adminBarView;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *soldButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTextViewWidth;

@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;

- (IBAction)repostButtonPressed:(id)sender;
- (IBAction)soldButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;
- (IBAction)purchaseButtonPressed:(id)sender;

@end
