//
//  PostTypeViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/17/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "PostTypeViewController.h"
#import "AppDelegate.h"
#import "PostTableViewCell.h"
#import "PostDetailViewController.h"
#import "UIColor+SpreeColor.h"
#import "SpreePost.h"

#import <Parse/Parse.h>

#define headerHeight 35.0;

@interface PostTypeViewController () {
    UIRefreshControl *refreshControl;
}

@property NSArray *returnedPosts;
@property NSArray *returnedPostsWithinTwoMiles;
@property NSArray *returnedPostsFartherThanTwoMiles;
@property PFQuery *query;
@property (strong, nonatomic) NSMutableArray* filteredTableData;
@property BOOL isFiltered;

@end

@implementation PostTypeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [_postMapView setHidden:YES];
    self.navigationItem.title = _postType;
    _postTableView.delegate = self;
    _postTableView.dataSource = self;
    _postMapView.delegate = self;

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self queryForPostType:_postType];
    
    
    [self postToMap];
    
    [self setUpBackgroundGradient];
    
    _postTableView.backgroundColor = [UIColor clearColor];
    _postTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    self.searchBar.delegate = self;
    self.postSearchDisplayController = [[UISearchDisplayController alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search posts";
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.tintColor = [UIColor blackColor];
    self.searchBar.backgroundColor = [UIColor whiteColor];
    
    
    self.postSearchDisplayController.delegate = self;
    self.postSearchDisplayController.searchResultsDelegate = self;
    self.postSearchDisplayController.searchResultsDataSource =self;
    
    _segmentedViewControl.tintColor = [UIColor whiteColor];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.postTableView addSubview:refreshControl];
    // Do any additional setup after loading the view.
}




-(void) viewDidAppear:(BOOL)animated{
    [self queryForPostType:_postType];
}

-(void) setUpBackgroundGradient{
    UIColor *typeBackgroundColor;
    if ([_postType isEqualToString:@"All"]){
        typeBackgroundColor = [UIColor spreeDarkBlue];
    } else if ([_postType isEqualToString:@"Books"]){
        typeBackgroundColor = [UIColor spreeDarkYellow];
    } else if ([_postType isEqualToString:@"Tickets"]){
        typeBackgroundColor = [UIColor spreeRed];
    } else if ([_postType isEqualToString:@"Electronics"]){
        typeBackgroundColor = [UIColor spreeLightYellow];
    } else if ([_postType isEqualToString:@"Free"]){
        typeBackgroundColor = [UIColor spreeBabyBlue];
    }
    CALayer *red = [CALayer layer];
    red.frame = self.view.bounds;
    red.backgroundColor = [typeBackgroundColor CGColor];
    red.opacity = 1.0f;
    [self.view.layer insertSublayer:red atIndex:0];
    
    CALayer *white = [CALayer layer];
    white.frame = self.view.bounds;
    white.backgroundColor = [[UIColor whiteColor] CGColor];
    white.opacity = 0.4f;
    [self.view.layer insertSublayer:white atIndex:1];
    
    UIImageView *spreeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.postTableView.center.y)-(100
                                                                                                             ), self.view.frame.size.width, 0)];
    spreeLogo.alpha = 0.3f;
    spreeLogo.contentMode = UIViewContentModeCenter;
    spreeLogo.image = [UIImage imageNamed:@"spreeLogoWhite"];
    
    [self.view addSubview:spreeLogo];

}

-(void)postToMap{
    for (SpreePost *post in _returnedPosts){
        CLLocation *location =
        [[CLLocation alloc] initWithLatitude:[(PFGeoPoint *)post.location latitude]longitude: [(PFGeoPoint *)post.location longitude]];
        MKPlacemark *postPlacemark = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:nil];
        [_postMapView addAnnotation:postPlacemark];
    }
}

-(void)queryForPostType:(NSString*)type{
    _query = [PFQuery queryWithClassName:@"Post"];
    [_query whereKey:@"expired" equalTo:[NSNumber numberWithBool:NO]];
    [_query whereKey:@"sold" equalTo:[NSNumber numberWithBool:NO]];
    if (![type isEqualToString:@"All"]){
        [_query whereKey:@"type" equalTo:type];
    }
    

    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocation *currentLocation=appDelegate.locationManager.location;
    [_query orderByDescending:@"createdAt"];
    [_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            _returnedPosts = objects;
            if (_returnedPosts.count == 0){
                
                // Display a message when the table is empty
                UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                
                messageLabel.text = @"No posts have been made in your area. Check back later.";
                messageLabel.textColor = [UIColor whiteColor];
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = NSTextAlignmentCenter;
                messageLabel.font = [UIFont fontWithName:@"EuphemiaUCAS" size:20];
                [messageLabel sizeToFit];
                
                _postTableView.backgroundView = messageLabel;
                _postTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            } else {
                _postTableView.tableHeaderView = self.searchBar;
                NSMutableArray *postsFartherThanTwoMiles = [[NSMutableArray alloc] init];
                NSMutableArray *postsWithinTwoMiles = [[NSMutableArray alloc] init];

                
                for (SpreePost *post in _returnedPosts){
                    PFGeoPoint *postGeoPoint = post.location;
                    CLLocation *postLocation = [[CLLocation alloc] initWithLatitude:postGeoPoint.latitude longitude:postGeoPoint.longitude];
                    CLLocationDistance distance = [postLocation distanceFromLocation:currentLocation];
                    float distanceInMiles = (distance*3.28084)/5280;
                    if (distanceInMiles < 2.0){
                        [postsWithinTwoMiles addObject:post];
                    } else {
                        [postsFartherThanTwoMiles addObject:post];
                    }
                }
                _returnedPostsWithinTwoMiles = postsWithinTwoMiles;
                _returnedPostsFartherThanTwoMiles = postsFartherThanTwoMiles;
                [self.postTableView reloadData];
        }
        }  else {
            
        }
    }];
}

#pragma mark - UITableViewDataSource


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    UIColor *typeBackgroundColor;
    if ([_postType isEqualToString:@"All"]){
        typeBackgroundColor = [UIColor spreeDarkBlue];
    } else if ([_postType isEqualToString:@"Books"]){
        typeBackgroundColor = [UIColor spreeDarkYellow];
    } else if ([_postType isEqualToString:@"Tickets"]){
        typeBackgroundColor = [UIColor spreeRed];
    } else if ([_postType isEqualToString:@"Electronics"]){
        typeBackgroundColor = [UIColor spreeLightYellow];
    } else if ([_postType isEqualToString:@"Free"]){
        typeBackgroundColor = [UIColor spreeBabyBlue];
    }
    // Background color
    headerView.backgroundColor = typeBackgroundColor;
    // White color
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.postTableView.bounds.size.width, 35)];
    whiteView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4f];
    [headerView addSubview:whiteView];
    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, whiteView.frame.size.width, whiteView.frame.size.height)];
    labelHeader.font = [UIFont fontWithName:@"Helvetica" size:16];
    labelHeader.textColor = [UIColor whiteColor];
    
    [headerView addSubview:labelHeader];

    if (section == 0 && _isFiltered !=YES){
        if (_returnedPostsWithinTwoMiles.count == 0) {
            return nil;
        } else {
            labelHeader.text =  @"Within two miles";
            
            return headerView;
        }
    } else if (section == 1 && _isFiltered !=YES){
        if (_returnedPostsFartherThanTwoMiles.count == 0) {
            return nil;
        } else {
            labelHeader.text =  @"Farther away";
            return headerView;
        }
    } else if (section == 0 && _isFiltered == YES){
        if (_returnedPosts.count == 0){
            return nil;
        } else {
            labelHeader.text = @"Search results";
            return headerView;
        }
    }

    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 && _isFiltered !=YES){
        if (_returnedPostsWithinTwoMiles.count == 0) {
            return 0;
        } else {
            return headerHeight;
        }
    } else if (section == 1 && _isFiltered !=YES){
        if (_returnedPostsFartherThanTwoMiles.count == 0) {
            return 0;
        } else {
            return headerHeight;
        }
    } else if (section == 0 && _isFiltered == YES){
        if (_returnedPosts.count == 0){
            return 0;
        } else {
            return headerHeight;
        }
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    int numberOfSections;
    if (_isFiltered == YES){
        return 1;
    } else {
        if (_returnedPosts.count > 0){
            _postTableView.backgroundView = nil;
            _postTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            if (_returnedPostsFartherThanTwoMiles.count > 0 || _returnedPostsWithinTwoMiles > 0){
                NSLog(@"returned posts called");
                numberOfSections = 2;
                return numberOfSections;
            }
        } else {
            
        }
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount;
    
    if(self.isFiltered){
        rowCount = _filteredTableData.count;
    }else{
        if (section == 0) {
            rowCount = _returnedPostsWithinTwoMiles.count;
        } else if (section == 1){
            rowCount =  _returnedPostsFartherThanTwoMiles.count;
        }
    }
    
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
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
     */
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

        
            SpreePost *post;
            if(_isFiltered){
                post = [_filteredTableData objectAtIndex:indexPath.row];
            }else{
                NSLog(@"Posts!!! %@", _returnedPostsFartherThanTwoMiles);
                if (indexPath.section == 0){
                    post = [_returnedPostsWithinTwoMiles objectAtIndex:indexPath.row];
                } else if (indexPath.section == 1){
                    post = [_returnedPostsFartherThanTwoMiles objectAtIndex:indexPath.row];
                }
            }
            
            cell.postTitleLabel.text = post.title;
            if ([post.price isEqualToString:@"0"] || [post.price isEqualToString:@"0.00"] || [post.type isEqualToString:@"Free"]){
                cell.priceLabel.text = @"Free";
            } else {
                cell.priceLabel.text = post.price;
            }
            PFFile *imageFile = post.imageFile;
            if (!(imageFile == nil)){
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error){
                        cell.postImageView.image = [UIImage imageWithData:data];
                    } else {
                        NSLog(@"error loading images");
                    }
                }];
            } else {
                if ([post.type isEqualToString:@"Tickets"]){
                cell.postImageView.image = [UIImage imageNamed:@"ticketGraphic"];
                } else if ([post.type isEqualToString:@"Books"]){
                    cell.postImageView.image = [UIImage imageNamed:@"booksGraphic"];
                } else if ([post.type isEqualToString:@"Electronics"]){
                    cell.postImageView.image = [UIImage imageNamed:@"electronicsGraphic"];
                } else if ([post.type isEqualToString:@"Free"]){
                    cell.postImageView.image = [UIImage imageNamed:@"electronicsGraphic"];
                }
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
    SpreePost *selectedObject;
    if (_isFiltered == YES){
        selectedObject = [_filteredTableData objectAtIndex:indexPath.row];
        return selectedObject;
    } else {
        if (indexPath.section == 0){
            selectedObject = [_returnedPostsWithinTwoMiles objectAtIndex:indexPath.row];
            return selectedObject;
        } else if (indexPath.section == 1) {
            selectedObject = [_returnedPostsFartherThanTwoMiles objectAtIndex:indexPath.row];
            return selectedObject;
        }
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[(SpreePost *)[self objectForRowAtIndexPath:_postTableView.indexPathForSelectedRow] type] isEqualToString:@"Free"]) {
        [self performSegueWithIdentifier:@"ShowFreeDetail" sender:self];
    } else{
        [self performSegueWithIdentifier:@"ShowDetail" sender:self];
        [self.postTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowDetail"] || [segue.identifier isEqualToString:@"ShowFreeDetail"]){
        PostDetailViewController *postDetailViewController = segue.destinationViewController;
        postDetailViewController.detailPost = [self objectForRowAtIndexPath:_postTableView.indexPathForSelectedRow];
        //
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}


- (IBAction)indexChanged:(id)sender {
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocation *currentLocation=appDelegate.locationManager.location;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1000, 1000);
    switch (_segmentedViewControl.selectedSegmentIndex){
        case 0:
            [_postTableView setHidden:NO];
            [_postMapView setHidden:YES];
            break;
        case 1:
            [_postTableView setHidden:YES];
            
            [_postMapView setHidden:NO];
            [self.searchBar resignFirstResponder];
            [self postToMap];
            [_postMapView setRegion:region];
            break;
        default: 
            break; 
    }
}

- (void)dealloc {
    self.postMapView.delegate = nil;
}

-(void)viewDidDisappear:(BOOL)animated {
    self.postMapView.delegate = nil;
    [_query cancel];
}


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
            NSRange descriptionRange = [post.title rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound)
            {
                [_filteredTableData addObject:post];
            }
        }
    }
    
    [self.postTableView reloadData];
    [self.searchBar becomeFirstResponder];
}

#pragma UIRefreshControl

-(void)refresh:(id)sender{
    [self queryForPostType:_postType];
    [refreshControl endRefreshing];
}


@end
