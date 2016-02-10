//
//  PostingDateEntryViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/24/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostingDataEntryViewController.h"
#import "PostingDateEntryViewModel.h"

@interface PostingDateEntryViewController : PostingDataEntryViewController

@property PostingDateEntryViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@end
