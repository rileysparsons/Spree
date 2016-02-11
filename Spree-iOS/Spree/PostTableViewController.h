//
//  PostDetailTableViewController.h
//  
//
//  Created by Riley Steele Parsons on 3/20/15.
//
//

#import "PostDetailTableViewController.h"
#import "PostTableViewModel.h"

@interface PostTableViewController : UIViewController


@property (nonatomic, strong) PostDetailTableViewController *postDetailTableViewController;
@property NSDictionary *postQueryParameters;
@property BOOL isSearchable;
@property PostTableViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UITableView *postsTableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (IBAction)NewPostBarButtonItemPressed:(id)sender;

@end
