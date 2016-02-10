//
//  EditPostingDateEntryViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/27/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "EditPostingDateEntryViewController.h"
#import "PreviewPostViewController.h"

@interface EditPostingDateEntryViewController ()

@end

@implementation EditPostingDateEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarButtons];
    // Do any additional setup after loading the view.
    [[self.viewModel.nextCommand.executionSignals switchToLatest] subscribeNext:^(id x) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)navigationBarButtons{
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    @weakify(self)
    self.cancelButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return [RACSignal return:nil];
    }];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.cancelButton]];
    
    self.nextButton= [[UIButton alloc] initWithFrame:CGRectZero];
    self.nextButton.tag = 2;
    self.nextButton.backgroundColor = [UIColor clearColor];
    [self.nextButton setTitle:@"Update" forState:UIControlStateNormal];
    [self.nextButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
    [self.nextButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateNormal];
    [self.nextButton sizeToFit];
    self.nextButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        self.viewModel.enteredDate = self.datePicker.date;
        return [self.viewModel.nextCommand execute:nil];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
}




@end
