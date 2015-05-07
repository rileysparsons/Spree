//
//  AllMessagesViewController.m
//  Spree
//
//  Created by Nick Young on 4/25/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "AllMessagesViewController.h"

#import "ChatView.h"
#import "MessagingTableViewCell.h"
#import "recent.h"
#import "common.h"
#import "converter.h"

@interface AllMessagesViewController ()

@end

@implementation AllMessagesViewController
- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {

        // The className to query on
        self.parseClassName = PF_RECENT_CLASS_NAME;

        self.title = @"Messages";

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;

        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Remove the tab bar count when we click on the tab
    UITabBarItem *item = self.tabBarController.tabBar.items[2];
    item.badgeValue = nil;

    [self loadObjects];
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
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

    NSLog(@"RECENTS OBJECTS: %@", object);

    static NSString *CellIdentifier = @"CellIdentifier";

    MessagingTableViewCell *cell = (MessagingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:object[PF_RECENT_UPDATEDACTION]];
    int counter = [object[PF_RECENT_COUNTER] intValue];

    // Configure Cell
    [cell.userLabel setText:[object[PF_RECENT_TOUSER] objectForKey:PF_USER_USERNAME]];
    [cell.lastMessageLabel setText:object[PF_RECENT_LASTMESSAGE]];
    [cell.timeLabel setText:TimeElapsed(seconds)];
    [cell.messageCountLabel setText:[NSString stringWithFormat:@"%d new", counter]];

    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Deleting object: %@", [self.objects objectAtIndex:indexPath.row]);
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath.row] withRowAnimation:UITableViewRowAnimationFade];
            [self loadObjects];
        }];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PFObject *recent = [self.objects objectAtIndex:indexPath.row];

    ChatView *chatView = [[ChatView alloc] initWith:recent[PF_RECENT_GROUPID] post:[recent objectForKey:PF_MESSAGE_POST]];

    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
    // Unhide the tabbar when we go back
    self.hidesBottomBarWhenPushed = NO;
}

@end