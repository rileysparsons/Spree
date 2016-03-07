//
//  UserPostsTableViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 3/20/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "UserPostsTableViewController.h"
#import "UserPostTableViewCell.h"
#import "SpreePost.h"
#import "UIColor+SpreeColor.h"

@interface UserPostsTableViewController ()

@end

@implementation UserPostsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = nil;
    [self.navigationItem setTitle:@"Your Posts"];
    // Do any additional setup after loading the view.
    [(RACSubject *)self.viewModel.refreshObserver sendNext:nil];
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{

    static NSString *CellIdentifier = @"Cell";

    UserPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"UserPostTableViewCell" owner:self options:nil];
        for(id currentObject in nibFiles){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (UserPostTableViewCell*)currentObject;
                break;
            }
        }
        
        
        SpreePost *post = (SpreePost *)object;
        
        cell.postTitleLabel.text = post.title;
        if (post.price ==0){
            cell.priceLabel.text = @"Free";
        } else {
            NSString *price = [NSString stringWithFormat:@"$%@", post.price];
            cell.priceLabel.text = price;
        }
        
        
        if  (post.removed == YES){
            cell.shadeView.hidden = NO;
            cell.statusLabel.text = @"Deleted";
            cell.statusLabel.font = [UIFont fontWithName:@"Lato-Bold" size:12];
            cell.statusLabel.textColor = [UIColor spreeRed];
        } else {
            if (post.expired == YES && post.sold == NO){
                cell.statusLabel.text = @"Expired";
                cell.statusLabel.font = [UIFont fontWithName:@"Lato-Bold" size:12];
                cell.statusLabel.textColor = [UIColor spreeRed];
            } else if (post.sold == YES){
                cell.shadeView.hidden = NO;
                cell.statusLabel.text = @"Sold";
                cell.statusLabel.textColor = [UIColor spreeDarkYellow];
            } else {
                cell.statusLabel.textColor = [UIColor spreeDarkBlue];
                cell.statusLabel.text = @"Active";
            }
        }

        
        if (post.photoArray.count != 0){
            PFFile *imageFile = (PFFile *)[post.photoArray objectAtIndex:0];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    cell.postImageView.image = image;
                    
                }
            }];
        } else {
            if ([post.type isEqualToString:@"Tickets"]){
                cell.postImageView.image = [UIImage imageNamed:@"TicketTypeIconSmall"];
            } else if ([post.type isEqualToString:@"Books"]){
                cell.postImageView.image = [UIImage imageNamed:@"BookTypeIconSmall"];
            } else if ([post.type isEqualToString:@"Electronics"]){
                cell.postImageView.image = [UIImage imageNamed:@"ElectronicsTypeIconSmall"];
            } else if ([post.type isEqualToString:@"Furniture"]){
                cell.postImageView.image = nil;
            } else if ([post.type isEqualToString:@"Clothing"]){
                cell.postImageView.image = nil;
            } else if ([post.type isEqualToString:@"Tasks"]){
                cell.postImageView.image = nil;
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
         cell.descriptionLabel.text = post.userDescription;
        return cell;
    }
    return nil;
}
*/
@end
