//
//  ChooseTypeTableViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/15/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "ChooseTypeTableViewController.h"
#import "WSCoachMarksView.h"
#import "MSCellAccessory.h"
#import "ChosenTypeTableViewCell.h"

@interface ChooseTypeTableViewController ()

@end

static NSArray *categories;

@implementation ChooseTypeTableViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageArray = [[NSArray alloc] initWithObjects:@"BookTypeIconSmall", @"TicketTypeIconSmall", @"ElectronicsTypeIconSmall", @"freeGraphic", nil, nil, nil, nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
      NSLog(@"Delegate: %@", self.delegate);
}

+ (NSArray *)categories {
    return [NSArray arrayWithObjects:@"Books", @"Tickets", @"Electronics", @"Free", @"Furniture", @"Clothing", @"Tasks", nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return categories.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Called");
    static NSString *CellIdentifier = @"Cell";
    
    ChosenTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"ChosenTypeTableViewCell" owner:self options:nil];
        for(id currentObject in nibFiles){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (ChosenTypeTableViewCell*)currentObject;
                break;
            }
        }
    }
    
    cell.typeImage.contentMode = UIViewContentModeScaleAspectFit;
    cell.typeLabel.text = [categories objectAtIndex:indexPath.row];
    
    cell.typeImage.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
    
    if ([cell.textLabel.text isEqualToString: _typeFormerlySelected]){
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:[UIColor blackColor]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChosenTypeTableViewCell *selectedCell = (ChosenTypeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [selectedCell setAccessoryView:[MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:[UIColor blackColor]]];
    
    NSString *selectedType = selectedCell.typeLabel.text;
    NSLog(@"%@", selectedType);
    [self.delegate chooseTypeTableViewController:self didFinishSelecting:selectedType];;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
