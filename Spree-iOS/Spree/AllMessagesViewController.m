//
//  AllMessagesViewController.m
//  Spree
//
//  Created by Nick Young on 4/25/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "AllMessagesViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ChatView.h"
#import "MessagingTableViewCell.h"
#import "recent.h"
#import "common.h"
#import "converter.h"
#import "SpreeUtility.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface AllMessagesViewController ()

@end

@implementation AllMessagesViewController
- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {

        // The className to query on
        self.parseClassName = PF_RECENT_CLASS_NAME;

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;

        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text= @"MESSAGES";
    titleLabel.textColor=[UIColor spreeOffBlack];
    titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size: 17.0];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=titleLabel;
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 75, 0, 0);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjectsOnDelay) name:@"reloadMessages" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Remove the tab bar count when we click on the tab
    UITabBarItem *item = self.tabBarController.tabBar.items[2];
    item.badgeValue = nil;

    [self loadObjects];
}

-(void)loadObjectsOnDelay{
    [self performSelector:@selector(loadObjects) withObject:nil afterDelay:0.5f];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    if (self.objects.count == 0){
        // Display a message when the table is empty
        messageLabel.text = @"Find something you like \nand message the seller here!";
        messageLabel.textColor = [UIColor spreeDarkBlue];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Lato-Regular" size:20];
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else if (self.objects.count > 0 ){
        self.tableView.backgroundView.hidden = YES;
    }
    // This method is called every time objects are loaded from Parse via the PFQuery
}


- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
    
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:PF_RECENT_POST matchesQuery:postQuery];
    [query includeKey:PF_RECENT_LASTUSER];
    [query includeKey:PF_RECENT_POST];
    [query includeKey:PF_RECENT_TOUSER];
    [query orderByDescending:PF_RECENT_UPDATEDACTION];
    return query;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)updateTabCounter
{
    int total = 0;
    for (PFObject *recent in self.objects)
    {
        total += [recent[PF_RECENT_COUNTER] intValue];
    }
    UITabBarItem *item = self.tabBarController.tabBar.items[2];
    item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {

    static NSString *CellIdentifier = @"CellIdentifier";

    MessagingTableViewCell *cell = (MessagingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:object[PF_RECENT_UPDATEDACTION]];
    int counter = [object[PF_RECENT_COUNTER] intValue];
    
    PFObject *recentPost = object[PF_RECENT_POST];
    
    // Configure Cell
    [cell.postLabel setText:[recentPost objectForKey:PF_POST_TITLE]];
    [cell.lastMessageLabel setText:object[PF_RECENT_LASTMESSAGE]];

    
    if (((NSArray *)(recentPost[PF_POST_PHOTOARRAY])).count > 0){
    
        PFFile *image = (PFFile *)[(NSArray *)((PFObject *)object[PF_RECENT_POST][PF_POST_PHOTOARRAY]) objectAtIndex:0];
        
        if (image){
            cell.postImageView.file = image;
            [cell.postImageView loadInBackground];
        }
    }
    
    NSString *path = object[PF_RECENT_TOUSER][@"fbId"];
    [[[FBSDKGraphRequest alloc] initWithGraphPath:path parameters:@{@"fields": @"email,name,first_name"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        cell.senderLabel.text =result[@"name"];
    }];
    
    if(object[PF_RECENT_TOUSER][@"fbId"]){
        cell.userImageView.profileID = object[PF_RECENT_TOUSER][@"fbId"];
        [cell.userImageView setNeedsImageUpdate];
    }
    
    [cell.timeLabel setText:TimeElapsed(seconds)];
//    [cell.messageCountLabel setText:[NSString stringWithFormat:@"%d new", counter]];
    if (counter > 0){
        [cell.messageFlag setHidden:NO];
    } else {
        [cell.messageFlag setHidden:YES];
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PFObject *recent = [self.objects objectAtIndex:indexPath.row];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[recent objectForKey:PF_MESSAGE_POST][@"typePointer"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (error){
            
        } else {
            [[recent objectForKey:PF_RECENT_TOUSER] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
                if (error){
                    
                } else {
                    NSString *path = object[@"fbId"];
                    [[[FBSDKGraphRequest alloc] initWithGraphPath:path parameters:@{@"fields": @"email,name,first_name"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        ChatView *chatView = [[ChatView alloc] initWith:recent[PF_RECENT_GROUPID] post:[recent objectForKey:PF_MESSAGE_POST] title:result[@"name"]];
                        chatView.toUser = (PFUser *)recent[PF_RECENT_TOUSER];
                        self.hidesBottomBarWhenPushed = YES;
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self.navigationController pushViewController:chatView animated:YES];
                        // Unhide the tabbar when we go back
                        self.hidesBottomBarWhenPushed = NO;
                    }];
                    
                }
            }];
        }
    }];

}

@end