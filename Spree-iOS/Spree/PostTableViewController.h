//
//  PostDetailTableViewController.h
//  
//
//  Created by Riley Steele Parsons on 3/20/15.
//
//

#import "PostDetailTableViewController.h"

@interface PostTableViewController : PFQueryTableViewController


@property (nonatomic, strong) PostDetailTableViewController *postDetailTableViewController;
@property NSDictionary *postQueryParameters;

- (IBAction)NewPostBarButtonItemPressed:(id)sender;
-(void)setupRefreshControl;

@end
