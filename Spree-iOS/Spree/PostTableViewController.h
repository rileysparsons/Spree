//
//  PostDetailTableViewController.h
//  
//
//  Created by Riley Steele Parsons on 3/20/15.
//
//

#import "PostDetailTableViewController.h"
#import "PostTableViewModel.h"

@interface PostTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) PostDetailTableViewController *postDetailTableViewController;
@property NSDictionary *postQueryParameters;
@property PostTableViewModel *viewModel;

- (IBAction)NewPostBarButtonItemPressed:(id)sender;
-(void)setupRefreshControl;

@end
