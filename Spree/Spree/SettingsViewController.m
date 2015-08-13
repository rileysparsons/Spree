//
//  SettingsViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/9/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SettingsViewController.h"
#import  <MSCellAccessory/MSCellAccessory.h>
#import  <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "TextViewViewController.h"

#define kTermsAndConditionsTitle @"Terms and Conditions"
#define kContactUsTitle @"Contact Us"
#define kDeauthorizeFacebookTitle @"Deauthorize Facebook"

@interface SettingsViewController ()

@property NSArray *firstSectionArray;
@property NSArray *secondSectionArray;

@end

@implementation SettingsViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    [self updateTableViewModel];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateTableViewModel];
    [self.tableView reloadData];
}

-(void)updateTableViewModel{
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        self.firstSectionArray = [[NSArray alloc] initWithObjects:kTermsAndConditionsTitle, kContactUsTitle, kDeauthorizeFacebookTitle, nil];
    } else {
        self.firstSectionArray = [[NSArray alloc] initWithObjects:kTermsAndConditionsTitle, kContactUsTitle, nil];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 35)];
//    UIColor *typeBackgroundColor = [UIColor spreeOffWhite];
//    
//    // Background color
//    headerView.backgroundColor = typeBackgroundColor;
//    
//    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 35)];
//    whiteView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4f];
//    [headerView addSubview:whiteView];
//    
//    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, whiteView.frame.size.width, whiteView.frame.size.height
//                                                                     )];
//    labelHeader.font = [UIFont fontWithName:@"Lato-Regular" size:16];
//    labelHeader.textColor = [UIColor spreeOffBlack];
//    
//    [whiteView addSubview:labelHeader];
//    
//    if (section == 0) {
//        labelHeader.text = @"Settings";
//    } else if (section == 1){
//        labelHeader.text = @"Other";
//    }
//    
//    
//    return headerView;
//    // Another way to set the background color
//    // Note: does not preserve gradient effect of original header
//    // header.contentView.backgroundColor = [UIColor blackColor];
//    
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0){
        return [_firstSectionArray count];
    }
    return 0;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0){
        cell.textLabel.text = [_firstSectionArray objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1){
        cell.textLabel.text = [_secondSectionArray objectAtIndex:indexPath.row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        if ([[self.firstSectionArray objectAtIndex:indexPath.row] isEqualToString:kTermsAndConditionsTitle]){
            [self performSegueWithIdentifier:@"showTerms" sender:self];
        }
        else if ([[self.firstSectionArray objectAtIndex:indexPath.row] isEqualToString:kContactUsTitle]){
            [self performSegueWithIdentifier:@"showContactUs" sender:self];
        } else if ([[self.firstSectionArray objectAtIndex:indexPath.row] isEqualToString:kDeauthorizeFacebookTitle]){
            [self deauthorizeFacebook];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showTerms"]) {
        TextViewViewController *destination = (TextViewViewController*)segue.destinationViewController;
        destination.textDisplayed = @"By logging into and using this application you are accepting responsibility for what you post and the interactions (communications, meet-ups, etc.) that emerge from the use of this service.\n\nSpree will not be held liable for any harm, theft, damages or liabilities that are facilitated by the use of Spree.\n\nYou may not sell anything illegal or anything that is explicit in nature through our service. You agree that you will abide by the rules, regulations and laws of your state when using this application.";
    }
}

-(void)deauthorizeFacebook{
    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.firstSectionArray indexOfObject:kDeauthorizeFacebookTitle]inSection:0];
        [self updateTableViewModel];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
    }];
}



@end
