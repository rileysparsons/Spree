//
//  PostPriceEntryViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/19/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostingDataEntryViewController.h"
#import "PostingNumberEntryViewModel.h"

@interface PostingNumberEntryViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;

@property PostingNumberEntryViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UIView *priceEntryView;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

- (NSNumber *)getNumberFromString:(NSString *)number;

@end
