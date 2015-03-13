//
//  NewPostTypeSelectionViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 3/8/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SpreePost.h"

@interface NewPostTypeSelectionViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *typePickerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;
@property SpreePost *post;


- (IBAction)nextBarButtonItemPressed:(id)sender;
- (IBAction)cancelBarButtonItemPressed:(id)sender;

@end
