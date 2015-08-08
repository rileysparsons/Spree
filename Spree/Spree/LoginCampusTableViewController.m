//
//  LoginCampusTableViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "LoginCampusTableViewController.h"
#import "LoginCampusHeaderView.h"
#import "SelectCampusTableViewCell.h"

@interface LoginCampusTableViewController ()
@property LoginCampusHeaderView *header;
@end

@implementation LoginCampusTableViewController

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithClassName:@"Campus"];
    self = [super initWithCoder:aCoder];
    if (self) {
        
        // The className to query on
        self.parseClassName = @"Campus";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
    }
    return self;
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query orderByDescending:@"userCount"];
    return query;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    self.header = [[LoginCampusHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    self.tableView.tableHeaderView = self.header;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PFObject *campus = [self objectAtIndexPath:indexPath];
    self.user[@"campus"] = campus;
    [self.delegate loginCampusTableViewController:self didSelectCampus:campus];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
    
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(nullable PFObject *)object{
    [super tableView:tableView cellForRowAtIndexPath:indexPath object:object];
    
    static NSString *CellIdentifier = @"Cell";
    
    SelectCampusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"SelectCampusTableViewCell" owner:self options:nil];
        for(id currentObject in nibFiles){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (SelectCampusTableViewCell*)currentObject;
                break;
            }
        }
    }
    cell.campusNameLabel.text = object[@"campusName"];
    cell.studentCountLabel.text = [NSString stringWithFormat:@"%ld students on Spree", [object[@"userCount"] integerValue]];
    cell.postCountLabel.text = [NSString stringWithFormat:@"%ld posts", [object[@"postCount"] integerValue]];
    return cell;
}



@end
