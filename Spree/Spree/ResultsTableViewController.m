//
//  ResultsTableViewController.m
//  
//
//  Created by Riley Steele Parsons on 6/18/15.
//
//

#import "ResultsTableViewController.h"
#import "PostTableViewCell.h"
#import "SpreePost.h"

@interface ResultsTableViewController ()

@end

@implementation ResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor spreeOffWhite];
    self.view.backgroundColor = [UIColor spreeOffWhite];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        
        
        SpreePost *post = self.filteredProducts[indexPath.row];
        
        cell.postTitleLabel.text = post.title;
        if (post.price == 0 || [post.price  isEqual: @(0)]){
            cell.priceLabel.text = @"Free";
        } else {
            float priceFloat = [post.price floatValue];
            NSString *price = [NSString stringWithFormat:@"$%.2f", priceFloat];
            cell.priceLabel.text = price;
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
            cell.typeIcon.hidden = NO;
            cell.postImageView.hidden = YES;
            if ([post.type isEqualToString:@"Tickets"]){
                cell.typeIcon.image = [UIImage imageNamed:@"TicketTypeIconSmall"];
            } else if ([post.type isEqualToString:@"Books"]){
                cell.typeIcon.image = [UIImage imageNamed:@"BookTypeIconSmall"];
            } else if ([post.type isEqualToString:@"Electronics"]){
                cell.typeIcon.image = [UIImage imageNamed:@"ElectronicsTypeIconSmall"];
            } else if ([post.type isEqualToString:@"Furniture"]){
                cell.typeIcon.image =[UIImage imageNamed:@"furnitureCellIconWhite"];
            } else if ([post.type isEqualToString:@"Clothing"]){
                cell.typeIcon.image =[UIImage imageNamed:@"clothingCellIconWhite"];
            } else if ([post.type isEqualToString:@"Tasks"]){
                cell.typeIcon.image =[UIImage imageNamed:@"sprintCellIconWhite"];
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

@end
