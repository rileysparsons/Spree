 //
//  UserPostTableViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/27/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "UserPostTableViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "PostTableViewCell.h"
#import "PostDetailViewController.h"
#import "SpreePost.h"
#import "UIColor+SpreeColor.h"

@interface UserPostTableViewController ()

@property PFQuery *query;
@property NSArray *returnedPosts;
@property BOOL isFiltered;
@property (strong, nonatomic) NSMutableArray* filteredTableData;

@end

@implementation UserPostTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.title = @"Your Posts";
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.placeholder = @"Search your posts";
    
    self.postSearchDisplayController = [[UISearchDisplayController alloc] init];
    self.searchBar.delegate = self;
    self.postSearchDisplayController.delegate = self;
    self.postSearchDisplayController.searchResultsDelegate = self;
    self.postSearchDisplayController.searchResultsDataSource =self;
    
    
    [self queryForPosts];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)queryForPosts{
    _query = [PFQuery queryWithClassName:@"Post"];
    [_query whereKey:@"user" equalTo:[PFUser currentUser]];
    [_query orderByDescending:@"createdAt"];
    [_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            _returnedPosts = objects;
            NSLog(@"%@", _returnedPosts);
            [self.tableView reloadData];
            if (_returnedPosts.count == 0){
                UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                
                messageLabel.text = @"Go post something!";
                messageLabel.textColor = [UIColor blackColor];
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = NSTextAlignmentCenter;
                messageLabel.font = [UIFont fontWithName:@"EuphemiaUCAS" size:20];
                [messageLabel sizeToFit];
                
                self.tableView.backgroundView = messageLabel;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                            }
        }
    }];
    
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger rowCount;
    if(self.isFiltered)
        rowCount = _filteredTableData.count+1;
    else
        rowCount = _returnedPosts.count+1;
    
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"SearchCell";
        UITableViewCell *searchBarCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [searchBarCell addSubview:self.searchBar];
        return searchBarCell;
    } else {
        static NSString *CellIdentifier = @"Cell";
        
        PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (PostTableViewCell*)currentObject;
                    break;
                }
            }
        }
        
        SpreePost *post;
        if(_isFiltered)
            post = [_filteredTableData objectAtIndex:indexPath.row-1];
        else
            post = [_returnedPosts objectAtIndex:indexPath.row-1];
        
        cell.postTitleLabel.text = post.title;
        cell.priceLabel.text = post.price;
        if (post.expired == YES && post.sold == NO){
            cell.statusLabel.text = @"Expired";
            cell.statusLabel.textColor = [UIColor spreeRed];
        } else if (post.sold == YES){
            cell.statusLabel.text = @"Sold";
            cell.statusLabel.textColor = [UIColor spreeDarkYellow];
        } else {
            cell.statusLabel.textColor = [UIColor spreeDarkBlue];
            cell.statusLabel.text = @"Active";
        }
        
        PFFile *imageFile = post.imageFile;
        if (!(imageFile == nil)){
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.postImageView.image = [UIImage imageWithData:data];
            }];
        } else {
            
        }
        
        NSDate *dateCreatedGMT = [post updatedAt];
        NSTimeInterval timeSince = dateCreatedGMT.timeIntervalSinceNow;
        double timeSinceInDays = timeSince/60/60/24*(-1);
        if (timeSinceInDays > 1){
            double roundedValue = round(timeSinceInDays);
            int roundedInteger = (int)roundedValue;
            NSNumber *numberSince = [NSNumber numberWithInt:roundedInteger];
            NSString *timeSincePost = [numberSince stringValue];
            NSString *timeWithUnits = [NSString stringWithFormat:(@"%@d"), timeSincePost];
            cell.postTimeLabel.text = timeWithUnits;
        } else {
            double timeSinceInHours = timeSinceInDays*24;
            if (timeSinceInHours > 1){
                double timeSinceInHoursRounded = round(timeSinceInHours);
                int roundedInteger = (int)timeSinceInHoursRounded;
                NSNumber *numberSince = [NSNumber numberWithInt:roundedInteger];
                NSString *timeSincePost = [numberSince stringValue];
                NSString *timeWithUnits = [NSString stringWithFormat:(@"%@h"), timeSincePost];
                cell.postTimeLabel.text = timeWithUnits;
            } else {
                double timeSinceInMinutes = timeSinceInHours*60;
                int roundedInteger = (int)timeSinceInMinutes;
                NSNumber *numberSince = [NSNumber numberWithInt:roundedInteger];
                NSString *timeSincePost = [numberSince stringValue];
                NSString *timeWithUnits = [NSString stringWithFormat:(@"%@m"), timeSincePost];
                cell.postTimeLabel.text = timeWithUnits;
            }
        }
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[self objectForRowAtIndexPath:self.tableView.indexPathForSelectedRow].type isEqualToString:@"Free"]){
        [self performSegueWithIdentifier:@"ShowFreeUserPost" sender:self];
    } else if ([[self objectForRowAtIndexPath:self.tableView.indexPathForSelectedRow].type isEqualToString:@"Tickets"]){
        [self performSegueWithIdentifier:@"showUserTicketsPost" sender:self];
    } else if ([[self objectForRowAtIndexPath:self.tableView.indexPathForSelectedRow].type isEqualToString:@"Electronics"]){
        [self performSegueWithIdentifier:@"showUserElectronicsPost" sender:self];
    } else if ([[self objectForRowAtIndexPath:self.tableView.indexPathForSelectedRow].type isEqualToString:@"Books"]){
        [self performSegueWithIdentifier:@"detailBookPost" sender:self];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


-(SpreePost* )objectForRowAtIndexPath:(NSIndexPath *)indexPath {
    SpreePost *selectedObject = [_returnedPosts objectAtIndex:indexPath.row-1];
    return selectedObject;
}


/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        _isFiltered = FALSE;
    }
    else
    {
        _isFiltered = true;
        _filteredTableData = [[NSMutableArray alloc
                               ] init];
        
        for (SpreePost *post in _returnedPosts)
        {
            NSRange nameRange = [post.title rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [post.userDescription rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound)
            {
                [_filteredTableData addObject:post];
            }
        }
    }
    [self.tableView reloadData];
    [self.searchBar becomeFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowFreeUserPost"]){
        PostDetailViewController *postDetailViewController = segue.destinationViewController;
        postDetailViewController.detailPost = [self objectForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    } else if ([segue.identifier isEqualToString:@"showUserTicketsPost"]){
        PostDetailViewController *postDetailViewController = segue.destinationViewController;
        postDetailViewController.detailPost = [self objectForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    }else if ([segue.identifier isEqualToString:@"showUserElectronicsPost"]){
        PostDetailViewController *postDetailViewController = segue.destinationViewController;
        postDetailViewController.detailPost = [self objectForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    }else if ([segue.identifier isEqualToString:@"detailBookPost"]){
        PostDetailViewController *postDetailViewController = segue.destinationViewController;
        postDetailViewController.detailPost = [self objectForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    }
}

@end
