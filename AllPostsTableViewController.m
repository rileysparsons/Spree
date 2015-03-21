//
//  AllPostsTableViewController.m
//  
//
//  Created by Riley Steele Parsons on 3/20/15.
//
//

#import "AllPostsTableViewController.h"
#import "PostTableViewCell.h"
#import "SpreePost.h"
#import "PostDetailViewController.h"

@interface AllPostsTableViewController ()

@end

@implementation AllPostsTableViewController

-  (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithClassName:@"Post"];
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"Post";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"title";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}


- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query orderByDescending:@"updatedAt"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
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
        
        
        SpreePost *post = (SpreePost *)object;
        
        cell.postTitleLabel.text = post.title;
        if ([post.price isEqualToString:@"0"] || [post.price isEqualToString:@"0.00"] || [post.type isEqualToString:@"Free"]){
            cell.priceLabel.text = @"Free";
        } else {
            NSString *price = [NSString stringWithFormat:@"$%@", post.price];
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
            if ([post.type isEqualToString:@"Tickets"]){
                cell.postImageView.image = [UIImage imageNamed:@"ticketGraphic"];
            } else if ([post.type isEqualToString:@"Books"]){
                cell.postImageView.image = [UIImage imageNamed:@"booksGraphic"];
            } else if ([post.type isEqualToString:@"Electronics"]){
                cell.postImageView.image = [UIImage imageNamed:@"electronicsGraphic"];
            } else if ([post.type isEqualToString:@"Free"]){
                cell.postImageView.image = [UIImage imageNamed:@"freeGraphic"];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark - Navigation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[(SpreePost *)[self objectAtIndexPath:indexPath] type] isEqualToString:@"Free"]) {
        [self performSegueWithIdentifier:@"ShowFreeDetail" sender:self];
    } else if ([[(SpreePost *)[self objectAtIndexPath:indexPath] type] isEqualToString:@"Books"]){
        [self performSegueWithIdentifier:@"detailBookPost" sender:self];
    } else if ([[(SpreePost *)[self objectAtIndexPath:indexPath] type] isEqualToString:@"Tickets"]){
        [self performSegueWithIdentifier:@"TicketsPostDetail" sender:self];
    } else if ([[(SpreePost *)[self objectAtIndexPath:indexPath] type] isEqualToString:@"Electronics"]){
        [self performSegueWithIdentifier:@"showElectronicsPost" sender:self];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


 -(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
 if ([segue.identifier isEqualToString:@"ShowFreeDetail"] || [segue.identifier isEqualToString:@"detailBookPost"] || [segue.identifier isEqualToString:@"TicketsPostDetail"] || [segue.identifier isEqualToString:@"showElectronicsPost"]){
         PostDetailViewController *postDetailViewController = segue.destinationViewController;
         postDetailViewController.detailPost = (SpreePost *)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
 }
}

@end
