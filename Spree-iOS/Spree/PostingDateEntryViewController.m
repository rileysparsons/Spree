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


-(void)initWithField:(NSDictionary *)field post:(SpreePost *)post{
    [super initWithField:field post:post];
    
}

-(void)initWithField:(NSDictionary *)field postingWorkflow:(PostingWorkflowViewModel *)postingWorkflow{
    [super initWithField:field postingWorkflow:postingWorkflow];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupPicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupPicker{
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    NSDate *date = [NSDate date];
    [self.datePicker setDate:date];
}

-(void)nextBarButtonItemTouched:(id)sender{

    if (self.presentedWithinWorkflow){
        self.postingWorkflow.post[self.fieldTitle] = self.datePicker.date;
        [self.postingWorkflow.post[@"completedFields"] addObject:self.fieldDictionary];
        self.postingWorkflow.step++;
        
        UIViewController *nextViewController =[self.postingWorkflow nextViewController];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

@end
