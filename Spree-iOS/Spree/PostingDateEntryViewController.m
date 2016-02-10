//
//  PostingDateEntryViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/24/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostingDateEntryViewController.h"

@interface PostingDateEntryViewController ()

@end

@implementation PostingDateEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupPicker];
    [self bindViewModel];
}

-(void)bindViewModel{
    if (self.viewModel.enteredDate != nil) self.datePicker.date = self.viewModel.enteredDate;
    RAC(self.viewModel, enteredDate) = RACObserve(self.datePicker, date);
    @weakify(self)
    self.nextButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        self.viewModel.enteredDate = self.datePicker.date;
        return [self.viewModel.nextCommand execute:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupPicker{
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    NSDate *date = [NSDate date];
    self.datePicker.minimumDate = date;
    [self.datePicker setDate:date];
}



@end
