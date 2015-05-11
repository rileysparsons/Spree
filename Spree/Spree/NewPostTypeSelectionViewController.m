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

@interface NewPostTypeSelectionViewController (){
    NSArray *typeArray;
}

@end

@implementation NewPostTypeSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    typeArray = [[NSArray alloc] initWithObjects:@"Electronics", @"Free", @"Tickets", @"Books", @"Furniture", @"Clothing", nil];
    
    self.navigationItem.title = @"Choose post type";
    
    self.post = [[SpreePost alloc] init];
    self.typeTableView.delegate = self;
    self.typeTableView.dataSource =self;
    
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
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeDarkYellow] highlightedColor:[UIColor spreeLightYellow]];
        cell.detailImage.image = [UIImage imageNamed:@"BookTypeIconSmall"];
    } else if ([[typeArray objectAtIndex:indexPath.row] isEqualToString: @"Tickets"]){
        cell.detailImage.image = [UIImage imageNamed:@"TicketTypeIconSmall"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeRed] highlightedColor:[UIColor spreeLightYellow]];
    } else if ([[typeArray objectAtIndex:indexPath.row] isEqualToString: @"Electronics"]){
        cell.detailImage.image = [UIImage imageNamed:@"ElectronicsTypeIconSmall"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeLightYellow] highlightedColor:[UIColor spreeLightYellow]];
    } else if ([[typeArray objectAtIndex:indexPath.row] isEqualToString: @"Free"]){
        cell.detailImage.image = [UIImage imageNamed:@"freeGraphic"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeBabyBlue] highlightedColor:[UIColor spreeLightYellow]];
    } else if ([[typeArray objectAtIndex:indexPath.row] isEqualToString: @"Furniture"]){
        cell.detailImage.image = nil;
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeRed] highlightedColor:[UIColor spreeLightYellow]];
    } else if ([[typeArray objectAtIndex:indexPath.row] isEqualToString: @"Clothing"]){
        cell.detailImage.image = nil;
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeLightYellow] highlightedColor:[UIColor spreeLightYellow]];
    }
    return cell;

}

- (void)nextBarButtonItemPressed:(id)sender {
    NSString *selectedType = [[(PostTypeTableViewCell *)[self.typeTableView cellForRowAtIndexPath:self.typeTableView.indexPathForSelectedRow] titleLabel] text];
    if ([selectedType isEqualToString:@"Free"]){
        [self performSegueWithIdentifier:@"showNewFreePostDetail" sender:self];
    } else if ([selectedType isEqualToString:@"Books"]) {
        [self performSegueWithIdentifier:@"showNewBooksPostDetail" sender:self];
    } else if ([selectedType isEqualToString:@"Electronics"]) {
        [self performSegueWithIdentifier:@"showNewElectronicsPostDetail" sender:self];
    } else if ([selectedType isEqualToString:@"Tickets"]){
        [self performSegueWithIdentifier:@"showNewTicketsPostDetail" sender:self];
    } else if ([selectedType isEqualToString:@"Furniture"]){
        [self performSegueWithIdentifier:@"showNewFurniturePostDetail" sender:self];
    } else if ([selectedType isEqualToString:@"Clothing"]){
        [self performSegueWithIdentifier:@"showNewClothingPostDetail" sender:self];
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
