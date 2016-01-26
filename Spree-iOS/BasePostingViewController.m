//
//  BasePostingViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 1/20/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "BasePostingViewController.h"
#import "SelectPostTypeViewController.h"
#import "SelectPostTypeViewModel.h"
#import "SelectPostSubTypeViewController.h"
#import "SelectPostSubTypeViewModel.h"
#import "SpreeViewModelServicesImpl.h"

@interface BasePostingViewController ()

@property PostingWorkflowViewModel *viewModel;

@property NSMutableArray *workflowViewControllers;

@property SelectPostTypeViewController *selectPostTypeViewController;
@property SelectPostSubTypeViewController *selectPostSubTypeViewController;

@end

@implementation BasePostingViewController

-(instancetype) initWithViewModel:(PostingWorkflowViewModel *)viewModel{
    self = [super init];
    if (self) {
        _viewModel = viewModel;
        [self initialize];
    }
    return self;
}

-(void)initialize{
    [self bindToViewModel];
}

-(void)bindToViewModel{
    [self.viewModel.presentNextViewControllerSignal subscribeNext:^(id x) {
        [self.navigationController pushViewController:[self.viewModel.viewControllersForPresentation objectAtIndex:self.viewModel.step] animated:YES];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController pushViewController:[self.viewModel.viewControllersForPresentation objectAtIndex:0] animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
