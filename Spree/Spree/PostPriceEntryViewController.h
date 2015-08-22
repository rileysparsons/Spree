//
//  PostPriceEntryViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/19/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostingDataEntryViewController.h"

@interface PostPriceEntryViewController : PostingDataEntryViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;

@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UIView *priceEntryView;


@end
