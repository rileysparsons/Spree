//
//  ResultsTableViewController.m
//  
//
//  Created by Riley Steele Parsons on 6/18/15.
//
//

#import "ResultsTableViewController.h"
#import "PostTableViewCell.h"
#import "SpreePost.h"

@interface ResultsTableViewController ()

@end

@implementation ResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

-(void)presentDetailViewControllerForPost:(SpreePost *)post {
    PostDetailTableViewController *postDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PostDetail"];
    
    [postDetailViewController initWithPost:post];
    
    [self.presentingViewController.navigationController pushViewController:postDetailViewController animated:YES];
}



@end
