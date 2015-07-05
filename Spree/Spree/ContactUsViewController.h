//
//  ContactUsViewController.h
//  Spree
//
//  Created by Hamilton Coke on 7/4/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactUsViewController : UIViewController
@property NSString *contactUsTextDisplayed;
@property UIButton *siteButton;
@property (weak, nonatomic) IBOutlet UITextView *contactUsTextView;

@end