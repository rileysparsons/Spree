//
//  PostingDataEntryViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/21/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostingDataEntryViewController.h"

@interface PostingDataEntryViewController ()

@end

@implementation PostingDataEntryViewController

-(void)initWithField:(NSDictionary *)field post:(SpreePost *)post{
    self.presentedWithinWorkflow = NO;
    self.prompt = field[@"prompt"];
    self.fieldDictionary = field;
    self.fieldTitle = field[@"field"];
    self.post = post;
}

-(void)initWithField:(NSDictionary *)field postingWorkflow:(PostingWorkflowViewModel *)postingWorkflow{
    self.presentedWithinWorkflow = YES;
    self.prompt = field[@"prompt"];
    self.fieldDictionary = field;
    self.fieldTitle = field[@"field"];
    self.postingWorkflow = postingWorkflow;
    self.clientFacingName = field[@"name"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarButtons];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text= [self.clientFacingName uppercaseString];
    titleLabel.textColor=[UIColor spreeOffBlack];
    titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size: 15];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=titleLabel;
}

-(void)navigationBarButtons{
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
    [self.nextButton addTarget:self action:@selector(nextBarButtonItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
    [self.navigationItem setRightBarButtonItems:@[nextBarButtonItem] animated:YES];
}

-(void)cancelWorkflow{
    [[[UIAlertView alloc] initWithTitle:@"Cancel Post" message:@"Are you sure you want to cancel this post? You are able to edit the post prior to publishing." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Confirm", nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex ==  0){
        self.postingWorkflow = nil;
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if (buttonIndex == 1){
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

- (void)nextBarButtonItemTouched:(id)sender {

}


@end
