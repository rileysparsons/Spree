//
//  PostTypeViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/28/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostTypeViewController.h"

@interface PostTypeViewController ()
@property (retain, nonatomic) NSIndexPath *currentIndexPath;
@end

@implementation PostTypeViewController


- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        
        // The className to query on
        self.parseClassName = @"PostType";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query orderByDescending:@"count"];
    [query includeKey:@"subType"];
    return query;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    NSLog(@"Choose user OBJECTS: %@", object);
    
    static NSString *CellIdentifier = @"cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [object objectForKey:@"type"];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

#pragma mark - Table view delegate

- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
