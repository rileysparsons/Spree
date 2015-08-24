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
    self.fieldTitle = field[@"field"];
    self.post = post;
}

-(void)initWithField:(NSDictionary *)field postingWorkflow:(PostingWorkflow *)postingWorkflow{
    self.presentedWithinWorkflow = YES;
    self.prompt = field[@"prompt"];
    self.fieldTitle = field[@"field"];
    self.postingWorkflow = postingWorkflow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarButtons];
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
    self.postingWorkflow = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextBarButtonItemTouched:(id)sender {
    if (self.presentedWithinWorkflow){
        [self.postingWorkflow.post[@"completedFields"] addObject:self.fieldTitle];
        self.postingWorkflow.step++;
        UIViewController *nextViewController =[self.postingWorkflow nextViewController];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}


@end
