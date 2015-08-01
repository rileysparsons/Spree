//
//  FindBuyerViewController.m
//  Spree
//
//  Created by Nick Young on 5/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "FindBuyerViewController.h"
#import "RatingViewController.h"

@interface FindBuyerViewController ()
@property (retain, nonatomic) UIBarButtonItem *cancelButton;
@property (retain, nonatomic) NSIndexPath *currentIndexPath;
@end

@implementation FindBuyerViewController

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {

        // The className to query on
        self.parseClassName = @"Message";

        self.title = @"Select the Buyer";

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;

        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItems = @[self.cancelButton];
}

- (UIBarButtonItem *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
        [_cancelButton setTintColor:[UIColor whiteColor]];
    }
    return _cancelButton;
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"post" equalTo:self.post];
    [query whereKey:@"user" notEqualTo:[PFUser currentUser]];
    [query includeKey:@"user"];
    [query orderByDescending:PF_RECENT_UPDATEDACTION];
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {

    static NSString *CellIdentifier = @"cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [[object objectForKey:@"user"] objectForKey:@"username"];

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show_rating"]) {
        RatingViewController *destViewController = segue.destinationViewController;
        destViewController.user = [[self.objects objectAtIndex:self.currentIndexPath.row] objectForKey:@"user"];
        destViewController.ratingType = @"buyer";
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    self.currentIndexPath = indexPath;

    [self performSegueWithIdentifier:@"show_rating" sender:self];
}


- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end