//
//  BasePostingViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 1/20/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "BasePostingViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SelectPostTypeViewController.h"
#import "SelectPostTypeViewModel.h"
#import "SelectPostSubTypeViewController.h"
#import "SelectPostSubTypeViewModel.h"
#import "SpreeViewModelServicesImpl.h"

@interface BasePostingViewController ()

@property PostingWorkflowViewModel *viewModel;
@property MBProgressHUD *progressHUD;

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
        if (self.viewModel.viewControllersForPresentation.count > self.viewModel.step)
            [self.navigationController pushViewController:[self.viewModel.viewControllersForPresentation objectAtIndex:self.viewModel.step] animated:YES];
        else
            [self.navigationController pushViewController:[self.viewModel presentPreviewPostController] animated:YES];
    }];
    
    
    [[self.viewModel.endPostingWorkflowCommand.executionSignals switchToLatest] subscribeNext:^(id x) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
