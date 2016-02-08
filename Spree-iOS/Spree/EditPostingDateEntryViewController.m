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
/*
- (void)initWithField:(NSDictionary *)field post:(SpreePost *)post{
    [super initWithField:field post:post];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarButtons];
    // Do any additional setup after loading the view.
    if (self.post[self.fieldTitle]){
        self.datePicker.date = self.post[self.fieldTitle];
    }
}

-(void)navigationBarButtons{
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    
    self.cancelButton.tag = 1;
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [self.cancelButton addTarget:self action:@selector(doneWithEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
    
    self.nextButton= [[UIButton alloc] initWithFrame:CGRectZero];
    self.nextButton.tag = 2;
    self.nextButton.backgroundColor = [UIColor clearColor];
    [self.nextButton setTitle:@"Update" forState:UIControlStateNormal];
    [self.nextButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:17]];
    [self.nextButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateNormal];
    [self.nextButton sizeToFit];
    [self.nextButton addTarget:self action:@selector(doneWithEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
}
/*
- (void)doneWithEdit:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1){
        
    } else if (button.tag == 2){
        ((PreviewPostViewController*)((UINavigationController *)self.presentingViewController).topViewController).post[self.fieldTitle] = self.datePicker.date;
        [((PreviewPostViewController*)((UINavigationController *)self.presentingViewController).topViewController).tableView reloadData];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
 */


@end
