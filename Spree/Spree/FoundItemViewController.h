//
//  FoundItemViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/26/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostLocationViewController.h"

@interface FoundItemViewController : UIViewController <PostLocationViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *foundItem;
- (IBAction)whereButtonPressed:(id)sender;
- (IBAction)postButtonPressed:(id)sender;

@end
