//
//  PostingDataEntryViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/21/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostingWorkflow.h"

@interface PostingDataEntryViewController : UIViewController <UIAlertViewDelegate>

@property SpreePost *post;
@property PostingWorkflow *postingWorkflow;
@property NSString *fieldTitle;
@property NSDictionary *fieldDictionary;
@property UIButton *cancelButton;
@property UIButton *nextButton;
@property NSString *prompt;
@property NSString *clientFacingName;

@property BOOL presentedWithinWorkflow;

- (void)nextBarButtonItemTouched:(id)sender;
- (void)cancelWorkflow;

- (void)initWithField:(NSDictionary *)field postingWorkflow:(PostingWorkflow *)postingWorkflow;
- (void)initWithField:(NSDictionary *)field post:(SpreePost *)post;

@end
