//
//  EditPostFieldViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/19/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "EditPostFieldViewController.h"
#import <IQUIView+IQKeyboardToolbar.h>

@interface EditPostFieldViewController ()

@end

@implementation EditPostFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

-(void)navigationBarButtons{
    [super navigationBarButtons];
    // Override super class cancel button setup, so that the modal dismisses.
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    cancel.backgroundColor = [UIColor clearColor];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(doneWithEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
}

-(void)setupTextField{
    
    // Allow the keyboard toolbar to dismiss the view.
    [super setupTextField];
    [self.fieldTextView addRightButtonOnKeyboardWithText:@"Done" target:self action:@selector(doneWithEdit:) shouldShowPlaceholder:YES];
}

- (void)doneWithEdit:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1){
        
    } else if (button.tag == 2){
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
