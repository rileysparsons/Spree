//
//  LostAndFoundTableViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "LostAndFoundTableViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "PostTableViewCell.h"

@interface LostAndFoundTableViewController ()

@property PFQuery *query;
@property NSArray *returnedPosts;
@property BOOL isFiltered;
@property (strong, nonatomic) NSMutableArray* filteredTableData;

@end

@implementation LostAndFoundTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    self.searchBar.delegate = self;
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
    _query = [PFQuery queryWithClassName:@"LostAndFound"];
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocation *currentLocation=appDelegate.locationManager.location;
    [_query whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLocation: currentLocation] withinMiles:10.0];
    [_query orderByDescending:@"createdAt"];
    [_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            _returnedPosts = objects;
            NSLog(@"%@", _returnedPosts);
            [self.tableView reloadData];
            if (_returnedPosts.count == 0){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No posts nearby!" message:@"It doesn't look like anything has been found in your area." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
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
        
        PFObject *post;
        if(_isFiltered)
            post = [_filteredTableData objectAtIndex:indexPath.row-1];
        else
            post = [_returnedPosts objectAtIndex:indexPath.row-1];
        
        cell.postTitleLabel.text = [post objectForKey:@"title"];
        PFFile *imageFile = [post objectForKey:@"imageFile"];
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

-(PFObject* )objectForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *selectedObject = [_returnedPosts objectAtIndex:indexPath.row-1];
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
        
        for (PFObject *post in _returnedPosts)
        {
            NSRange nameRange = [post[@"title"] rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [post[@"userDescription"] rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound)
            {
                [_filteredTableData addObject:post];
            }
        }
    }
    [self.tableView reloadData];
    [self.searchBar becomeFirstResponder];
}


@end
