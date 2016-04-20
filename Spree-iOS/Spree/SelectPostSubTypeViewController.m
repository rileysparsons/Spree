//
//  SelectPostSubTypeViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SelectPostSubTypeViewController.h"
#import "CETableViewBindingHelper.h"
#import "PostTypeSelectionTableViewCell.h"
#import "SelectPostTypeHeaderView.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface SelectPostSubTypeViewController ()
@property NSArray *postSubTypes;
@property MBProgressHUD *progressHUD;
@end

@implementation SelectPostSubTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    cancel.backgroundColor = [UIColor clearColor];
    cancel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancel setImage:[UIImage imageNamed:@"backNormal_Dark"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"backHighlight_Dark"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(cancelWorkflow) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:cancel]];
    
    NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"SelectPostTypeHeaderView" owner:self options:nil];
    for(id currentObject in nibFiles){
        if ([currentObject isKindOfClass:[UIView class]]){
            self.header = currentObject;
            break;
        }
    }
    [self.header setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    [self.header layoutSubviews];
    self.tableView.tableHeaderView = self.header;
    
    self.header.titleLabel.text =  [NSString stringWithFormat:@"Great! What type of item is it?"];
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    // Do any additional setup after loading the view.
    
    [self bindViewModel];
}

 - (void)bindViewModel {
     RAC(self, postSubTypes) = RACObserve(self.viewModel, postSubTypes);
 
     // Helper that abstracts all the UITableView logic and delegation away from the view controller using RAC
     UINib *nib = [UINib nibWithNibName:@"PostSubTypeSelectionTableViewCell" bundle:nil];
     [CETableViewBindingHelper bindingHelperForTableView:self.tableView
     sourceSignal:RACObserve(self.viewModel, postSubTypes)
     selectionCommand:self.viewModel.subTypeSelectedCommand
     templateCell:nib];
     
     [[RACObserve(self.viewModel, isLoading) deliverOnMainThread] subscribeNext:^(id x) {
         self.progressHUD.labelText = @"Loading...";
         if ([x boolValue]){
             [self.progressHUD show:YES];
         } else {
             [self.progressHUD hide:YES afterDelay:0.5];
         }
     }];
 
 }

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view addSubview:self.progressHUD];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.active = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.viewModel.active = NO;
}

-(void)cancelWorkflow{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
