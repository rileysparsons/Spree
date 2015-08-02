//
//  AllPostsTableViewController.h
//  
//
//  Created by Riley Steele Parsons on 3/20/15.
//
//

#import "PostDetailTableViewController.h"
#import "RTWalkthroughPageViewController.h"

@interface PostTableViewController : PFQueryTableViewController <RTWalkthroughPageViewControllerDelegate>


@property (nonatomic, strong) PostDetailTableViewController *postDetailTableViewController;

-(NSArray *)fieldsForPostType:(NSString *)type;
- (IBAction)NewPostBarButtonItemPressed:(id)sender;
-(void)setupRefreshControl;

@end
