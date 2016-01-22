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


}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
    self.selectPostTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectPostTypeViewController"];
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    SelectPostTypeViewModel *selectPostTypeViewModel = [[SelectPostTypeViewModel alloc] initWithServices:viewModelServices];
    self.selectPostTypeViewController.viewModel = selectPostTypeViewModel;
    
    RAC(self.viewModel.post, typePointer) = [[self.selectPostTypeViewController.viewModel.typeSelectedCommand executionSignals] switchToLatest];

    
    [[[self.selectPostTypeViewController.viewModel.typeSelectedCommand executionSignals] switchToLatest] subscribeNext:^(PFObject *type) {
        self.selectPostSubTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectPostSubTypeViewController"];
        SelectPostSubTypeViewModel *selectPostSubTypeViewModel = [[SelectPostSubTypeViewModel alloc] initWithServices:viewModelServices type:type];
        self.selectPostSubTypeViewController.viewModel = selectPostSubTypeViewModel;
        [self.navigationController pushViewController:self.selectPostSubTypeViewController animated:YES];
    }];
    
    [self.navigationController pushViewController:self.selectPostTypeViewController animated:NO];
    
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
