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

@interface SearchablePostTableViewController () {
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

    [self setupResultsViewController];
}

-(void)setupResultsViewController {
    
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    
    PostTableViewModel *postTableViewModel = [[PostTableViewModel alloc] initWithServices:viewModelServices Params:self.viewModel.queryParameters];
    _resultsTableController = [[UIStoryboard  storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ResultsTableViewController"];
    
    _resultsTableController.viewModel = postTableViewModel;
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];

    [self.searchController.searchBar sizeToFit];
    self.postsTableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES

    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    
     self.definesPresentationContext = YES;

    [[[[self.searchController.searchBar.rac_textSignal throttle:0.5] distinctUntilChanged] deliverOnMainThread]
     subscribeNext:^(NSString *string) {
         _resultsTableController.viewModel.searchString = string;
         [_resultsTableController.viewModel.refreshPosts execute:nil];
     }];
    
    // Signal called from lifting delegate methods for activity
    [self.searchController.rac_isActiveSignal subscribeNext:^(id x) {
//        self.refreshControl.enabled = false;
//        self.refreshControl = nil;
    //    [self.postsTableView setContentInset:UIEdgeInsetsMake(26,0,0,0)];
    //    [self.postsTableView setScrollIndicatorInsets:UIEdgeInsetsMake(64,0,0,0)];
    }];
 
      // Signal called from lifting delegate methods for inactivity
    [self.searchController.rac_isInactiveSignal subscribeNext:^(id x) {
//        [super setupRefreshControl];
    //    [self.postsTableView setContentInset:UIEdgeInsetsMake(64,0,0,0)];
    //    [self.postsTableView setScrollIndicatorInsets:UIEdgeInsetsMake(64,0,0,0)];
    }];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

#pragma mark - UIStateRestoration

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the view state so it can be restored later
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchController = self.searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    
    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}



@end
