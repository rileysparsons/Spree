//
//  TextViewViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 2/9/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewViewController : UIViewController
@property NSString *textDisplayed;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
