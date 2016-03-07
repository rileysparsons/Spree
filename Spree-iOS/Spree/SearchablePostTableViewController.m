//
//  PostTypeTableViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 3/20/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SearchablePostTableViewController.h"
#import "SpreeViewModelServicesImpl.h"
#import "ResultsTableViewController.h"
#import "UISearchBar+RAC.h"
#import "UISearchController+RAC.h"
#import "UIColor+SpreeColor.h"

@interface SearchablePostTableViewController () <UISearchBarDelegate> {
}

// Search Controller
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) ResultsTableViewController *resultsTableController;

// for state restoration from search
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation SearchablePostTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem.title = @"Categories";

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.searchController.searchBar sizeToFit];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    self.postsTableView.tableHeaderView = self.searchController.searchBar;
    
    [[[[self.searchController.searchBar.rac_textSignal throttle:0.5] distinctUntilChanged] deliverOnMainThread]
     subscribeNext:^(NSString *string) {
         self.viewModel.searchString = string;
         [(RACSubject *)self.viewModel.refreshObserver sendNext:nil];
     }];
    
    [self.searchController.rac_isInactiveSignal subscribeNext:^(id x) {
        self.viewModel.searchString = nil;
         [(RACSubject *)self.viewModel.refreshObserver sendNext:nil];
    }];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

@end
