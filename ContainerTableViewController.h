//
//  ContainerTableViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h>
#import "SpreePost.h"

@interface ContainerTableViewController : UITableViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>

@property SpreePost *detailPost;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property PFObject *poster;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *soldButton;
@property (weak, nonatomic) IBOutlet UILabel *managePostLabel;

- (IBAction)purchaseButtonPressed:(id)sender;
- (IBAction)contactButtonPressed:(id)sender;
- (IBAction)repostButton:(id)sender;
- (IBAction)soldButtonPressed:(id)sender;

@end
