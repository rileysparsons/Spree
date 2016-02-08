//
//  PostPriceEntryViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/19/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostingNumberEntryViewController.h"
#import "PostingInputAccessoryView.h"

@interface PostingNumberEntryViewController (){
    NSNumber *maxCharacter;
}

@property UIButton *cancelButton;
@property UIButton *nextButton;
@property PostingInputAccessoryView *accessoryView;

@end

@implementation PostingNumberEntryViewController

-(void)bindToViewModel {
    RAC(self.viewModel, enteredString) = self.priceTextField.rac_textSignal;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Add a "textFieldDidChange" notification method to the text field control.

    [self formatPriceEntryView];
    self.priceTextField.delegate = self;
    self.promptLabel.text = self.viewModel.prompt;
    self.symbolLabel.text = @"$";
    
    [self bindToViewModel];
    
    [self navigationBarAppearance];
}

-(void)navigationBarAppearance{
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [self.cancelButton addTarget:self action:@selector(cancelWorkflow) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.cancelButton]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
    
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    self.nextButton.backgroundColor = [UIColor clearColor];
    [self.nextButton setImage:[UIImage imageNamed:@"forwardNormal_Dark"] forState:UIControlStateNormal];
    [self.nextButton setImage:[UIImage imageNamed:@"forwardHighlight_Dark"] forState:UIControlStateHighlighted];
    self.nextButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.nextButton.enabled = NO;
    self.nextButton.rac_command = self.viewModel.nextCommand;
    UIBarButtonItem *nextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
    [self.navigationItem setRightBarButtonItems:@[nextBarButtonItem] animated:YES];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    // TODO: put client facing name into viewmodel
    /*
     titleLabel.text= [self.clientFacingName uppercaseString];
     */
    titleLabel.textColor=[UIColor spreeOffBlack];
    titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size: 15];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=titleLabel;
}

-(void)cancelWorkflow{
    [[[UIAlertView alloc] initWithTitle:@"Cancel Post" message:@"Are you sure you want to cancel this post? You are able to edit the post prior to publishing." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Confirm", nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex ==  0){
        [self.priceTextField resignFirstResponder];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if (buttonIndex == 1){
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}


-(void)formatPriceEntryView{
    self.priceEntryView.layer.borderWidth = 0.5f;
    self.priceEntryView.layer.borderColor = [[UIColor spreeOffBlack] CGColor];
    self.priceEntryView.layer.cornerRadius = 5.0f;
}

- (NSNumber *)getNumberFromString:(NSString *)number{
    if ([number length] == 0) {
        return 0;
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    NSNumber *formattedNumber = [formatter numberFromString:number];
    return formattedNumber;
}

@end
