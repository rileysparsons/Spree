//
//  PaymentViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/25/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "SpreePost.h"

@interface PaymentViewController : UIViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>

@property SpreePost *post;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property PFObject *poster;
@property (weak, nonatomic) IBOutlet UIButton *purchaseRequestButton;



- (IBAction)submitPurchasePressed:(id)sender;


@end
