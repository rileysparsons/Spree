//
//  PostTypeTableViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 3/20/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostTypeTableViewController.h"
#import "ResultsTableViewController.h"
#import "UIColor+SpreeColor.h"
#import "WSCoachMarksView.h"

@interface PostTypeTableViewController (){
    WSCoachMarksView *coachMarksView;
}

// Search
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) ResultsTableViewController *resultsTableController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) PFQuery *searchQuery;
// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation PostTypeTableViewController

-  (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // The className to query on
        self.parseClassName = @"Post";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"title";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"spreeTitleStylized.png"];
    self.title = self.postType;
    self.view.backgroundColor = [UIColor spreeOffWhite];
    self.tableView.backgroundColor = [UIColor spreeOffWhite];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"ReloadTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"PostMade" object:nil];
    
    // Search set up (Excerpt from official Apple Example)
    
    _resultsTableController = [[ResultsTableViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    [self.resultsTableController.tableView setFrame:CGRectZero];
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    self.searchResults = [NSMutableArray array];
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed


    [self addCoachMarks];
}
-(void)viewWillAppear:(BOOL)animated{
    // Show coach marks
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShownForCompose"];
    if (coachMarksShown == NO) {
        // Don't show again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WSCoachMarksShownForCompose"];
        [[NSUserDefaults standardUserDefaults] synchronize];\
        // Or show coach marks after a second delay
        [coachMarksView performSelector:@selector(start) withObject:nil afterDelay:1.0f];
    }
    
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

-(void)addCoachMarks{
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{self.view.frame.size.width -45, 25},{35, 35}}],
                                @"caption": @"Post something on Spree!"
                                }
                            ];
    coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.tabBarController.view.bounds coachMarks:coachMarks];
    [self.tabBarController.view addSubview:coachMarksView];
    coachMarksView.maskColor = [UIColor colorWithWhite:1 alpha:.95];
    coachMarksView.lblCaption.textColor = [UIColor spreeBabyBlue];
    coachMarksView.lblCaption.font = [UIFont fontWithName:@"EuphemiaUCAS-Bold" size:24];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row] > self.objects.count -1 ) {
        return;
    } else {
        SpreePost *selectedPost = (tableView == self.tableView) ?
        self.objects[indexPath.row] : self.resultsTableController.filteredProducts[indexPath.row];
        
        self.postDetailTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PostDetail"];
        
        [self.postDetailTableViewController setFields:[self fieldsForPostType:[[self objectAtIndexPath:indexPath]objectForKey:PF_POST_TYPE]]];
        NSLog(@"%@", [self fieldsForPostType:[[self objectAtIndexPath:indexPath]objectForKey:PF_POST_TYPE]]);
        [self.postDetailTableViewController setPost:selectedPost];
        [self.navigationController pushViewController:self.postDetailTableViewController animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}



- (PFQuery *)queryForTable{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if ([self.postType isEqualToString:@"Free"]){
        PFQuery *query2 = [PFQuery queryWithClassName:self.parseClassName];
        [query2 whereKeyDoesNotExist:@"price"];
        [query whereKey:@"price" equalTo:[NSNumber numberWithFloat:0]];
        [query whereKey:@"expired" equalTo:[NSNumber numberWithBool:NO]];
        [query whereKey:@"sold" equalTo:[NSNumber numberWithBool:NO]];
        [query whereKey:@"network" equalTo:[[PFUser currentUser] objectForKey:@"network"]];
        PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:@[query,query2]];
        [finalQuery orderByDescending:@"updatedAt"];
        return finalQuery;
    }  else {
        [query whereKey:@"type" equalTo:self.postType];
        [query whereKey:@"expired" equalTo:[NSNumber numberWithBool:NO]];
        [query whereKey:@"sold" equalTo:[NSNumber numberWithBool:NO]];
        [query whereKey:@"network" equalTo:[[PFUser currentUser] objectForKey:@"network"]];
        [query orderByDescending:@"updatedAt"];
    }
    return query;
}

- (void)filterResults:(NSString *)searchTerm {
    if (self.searchQuery){
        [self.searchQuery cancel];
    }
    self.searchQuery = [PFQuery queryWithClassName:@"Post"];
    [self.searchQuery whereKeyExists:@"title"];  //this is based on whatever query you are trying to accomplish
    [self.searchQuery whereKeyExists:@"price"]; //this is based on whatever query you are trying to accomplish
    
    [self.searchQuery whereKey:@"title" matchesRegex:searchTerm modifiers:@"i"];
    
    
    [self.searchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            NSLog(@"%@", objects);
            NSLog(@"%lu", (unsigned long)objects.count);
            [self.searchResults removeAllObjects];
            [self.searchResults addObjectsFromArray:objects];
            // hand over the filtered results to our search results table
            ResultsTableViewController *tableController = (ResultsTableViewController *)self.searchController.searchResultsController;
            tableController.filteredProducts = self.searchResults;
            [tableController.tableView reloadData];
            self.searchQuery = nil;
        }
    }];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    self.pullToRefreshEnabled = NO;
    self.refreshControl.enabled = false;
    self.refreshControl = nil;
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    [self.tableView setContentInset:UIEdgeInsetsMake(26,0,0,0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(64,0,0,0)];
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    [super setupRefreshControl];
    [self.tableView setContentInset:UIEdgeInsetsMake(64,0,0,0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(64,0,0,0)];
    
    self.pullToRefreshEnabled = YES;
    // do something after the search controller is dismissed
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterResults:searchController.searchBar.text];
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
