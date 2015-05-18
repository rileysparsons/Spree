//
//  NewPostTypeSelectionViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 3/8/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "NewPostTypeSelectionViewController.h"
#import "NewPostInfoViewController.h"
#import "PostTypeTableViewCell.h"
#import "UIColor+SpreeColor.h"
#import "SpreeSprintTableViewCell.h"

@interface NewPostTypeSelectionViewController (){
    NSArray *typeArray;
    NSArray *iconColorArray;
}

@end

@implementation NewPostTypeSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    typeArray = [[NSArray alloc] initWithObjects:@"Electronics", @"Tickets", @"Books", @"Furniture", @"Clothing", @"Tasks", nil];
    
    self.navigationItem.title = @"Choose post type";
    
    self.post = [[SpreePost alloc] init];
    self.typeTableView.delegate = self;
    self.typeTableView.dataSource =self;
    self.typeTableView.separatorInset = UIEdgeInsetsMake(0, 75, 0, 0);
    
    iconColorArray = [[NSArray alloc] initWithObjects:[UIColor spreeDarkBlue], [UIColor spreeRed], [UIColor spreeBabyBlue], [UIColor spreeDarkYellow], [UIColor spreeLightYellow],[UIColor spreeDarkBlue], [UIColor spreeRed], [UIColor spreeBabyBlue], [UIColor spreeDarkYellow], [UIColor spreeLightYellow], nil];

}

#pragma mark - Table View

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self nextBarButtonItemPressed:self];
    [self.typeTableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return typeArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    PostTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostTypeTableViewCell" owner:self options:nil];
        for(id currentObject in nibFiles){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (PostTypeTableViewCell*)currentObject;
                break;
            }
        }
    }
    
    // Configure the cell with the textContent of the Post as the cell's text label
    

    cell.titleLabel.text = [typeArray objectAtIndex:indexPath.row];
    cell.numberLabel.hidden = YES;
    
    if ([[typeArray objectAtIndex:indexPath.row] isEqualToString: @"Books"]){
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[iconColorArray objectAtIndex:indexPath.row] highlightedColor:[UIColor spreeLightYellow]];
        cell.detailImage.image = [UIImage imageNamed:@"BookTypeIconSmall"];
        cell.iconBackground.backgroundColor = [iconColorArray objectAtIndex:indexPath.row];
    } else if ([[typeArray objectAtIndex:indexPath.row] isEqualToString: @"Tickets"]){
        cell.detailImage.image = [UIImage imageNamed:@"TicketTypeIconSmall"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[iconColorArray objectAtIndex:indexPath.row] highlightedColor:[UIColor spreeLightYellow]];
        cell.iconBackground.backgroundColor = [iconColorArray objectAtIndex:indexPath.row];
    } else if ([[typeArray objectAtIndex:indexPath.row] isEqualToString: @"Electronics"]){
        cell.detailImage.image = [UIImage imageNamed:@"ElectronicsTypeIconSmall"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[iconColorArray objectAtIndex:indexPath.row] highlightedColor:[UIColor spreeLightYellow]];
        cell.iconBackground.backgroundColor = [iconColorArray objectAtIndex:indexPath.row];
    } else if ([[typeArray objectAtIndex:indexPath.row] isEqualToString: @"Furniture"]){
        cell.detailImage.image = [UIImage imageNamed:@"furnitureCellIconWhite"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[iconColorArray objectAtIndex:indexPath.row] highlightedColor:[UIColor spreeLightYellow]];
        cell.iconBackground.backgroundColor = [iconColorArray objectAtIndex:indexPath.row];
    } else if ([[typeArray objectAtIndex:indexPath.row] isEqualToString: @"Clothing"]){
        cell.detailImage.image = [UIImage imageNamed:@"clothingCellIconWhite"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[iconColorArray objectAtIndex:indexPath.row] highlightedColor:[UIColor spreeLightYellow]];
        cell.iconBackground.backgroundColor = [iconColorArray objectAtIndex:indexPath.row];
    } else if ([[typeArray objectAtIndex:indexPath.row] isEqualToString: @"Tasks"]){
        SpreeSprintTableViewCell *sprintCell = [tableView dequeueReusableCellWithIdentifier:@"sprintCell"];
        if (sprintCell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"SpreeSprintTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    sprintCell = (SpreeSprintTableViewCell*)currentObject;
                    break;
                }
            }
        }
        sprintCell.subtitle.text = @"Post a Task";
        sprintCell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeDarkBlue] highlightedColor:[UIColor spreeLightYellow]];
        return sprintCell;
    }
    return cell;
}

- (void)nextBarButtonItemPressed:(id)sender {
    NSString *selectedType = [typeArray objectAtIndex:self.typeTableView.indexPathForSelectedRow.row];
    if ([selectedType isEqualToString:@"Books"]) {
        [self performSegueWithIdentifier:@"showNewBooksPostDetail" sender:self];
    } else if ([selectedType isEqualToString:@"Electronics"]) {
        [self performSegueWithIdentifier:@"showNewElectronicsPostDetail" sender:self];
    } else if ([selectedType isEqualToString:@"Tickets"]){
        [self performSegueWithIdentifier:@"showNewTicketsPostDetail" sender:self];
    } else if ([selectedType isEqualToString:@"Furniture"]){
        [self performSegueWithIdentifier:@"showNewFurniturePostDetail" sender:self];
    } else if ([selectedType isEqualToString:@"Clothing"]){
        [self performSegueWithIdentifier:@"showNewClothingPostDetail" sender:self];
    } else if ([selectedType isEqualToString:@"Tasks"]){
        [self performSegueWithIdentifier:@"showNewTasksPostDetail" sender:self];
    }
    [self.post setType:selectedType];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NewPostInfoViewController *newPostInfoViewController = (NewPostInfoViewController *)[segue destinationViewController];
    DDLogVerbose(@"POST: %@", self.post);

    [newPostInfoViewController setPost:self.post];
}

- (IBAction)cancelBarButtonItemPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}
@end
