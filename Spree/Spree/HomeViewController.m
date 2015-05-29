//
//  FirstViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "HomeViewController.h"
#import "PostTypeTableViewController.h"
#import "NewPostTypeSelectionViewController.h"
#import "PostTypeTableViewCell.h"
#import "WSCoachMarksView.h"
#import "SpreeSprintTableViewCell.h"

@interface HomeViewController () {
    WSCoachMarksView *coachMarksView;
    NSArray *iconColorArray;
}

@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *compass_background;
@property (nonatomic, strong) UIImageView *compass_spinner;
@property (assign) BOOL isRefreshIconsOverlap;
@property (assign) BOOL isRefreshAnimating;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.postTypeArray = [[NSArray alloc] initWithObjects:@"Tasks", @"Books", @"Tickets", @"Electronics", @"Free", @"Furniture", @"Clothing", nil];
    iconColorArray = [[NSArray alloc] initWithObjects:[UIColor spreeDarkBlue], [UIColor spreeRed], [UIColor spreeBabyBlue], [UIColor spreeDarkYellow], [UIColor spreeLightYellow],[UIColor spreeDarkBlue], [UIColor spreeRed], [UIColor spreeBabyBlue], [UIColor spreeDarkYellow], [UIColor spreeLightYellow], nil];
//    self.navigationItem.title = @"Spree";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    
    UIImage *image = [UIImage imageNamed:@"spreeTitleStylized.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    [self setupRefreshControl];
//    refreshControl = [[UIRefreshControl alloc] init];
//    refreshControl.tintColor = [UIColor spreeRed];
//    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
//    [self.tableView addSubview:refreshControl];
    [self addCoachMarks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refresh:(id)sender{
    [self.tableView reloadData];
 
}

-(void)viewWillAppear:(BOOL)animated{

    // Show coach marks
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShownForCompose"];
    if (coachMarksShown == NO) {
        // Don't show again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WSCoachMarksShownForCompose"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // Or show coach marks after a second delay
        [coachMarksView performSelector:@selector(start) withObject:nil afterDelay:1.0f];
    }
//    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
//    [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
//    [query includeKey:PF_RECENT_LASTUSER];
//    [query orderByDescending:PF_RECENT_UPDATEDACTION];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         if (objects)
//         {
//             int total = 0;
//             for (PFObject *recent in objects)
//             {
//                 total += [recent[PF_RECENT_COUNTER] intValue];
//             }
//             UITabBarItem *item = self.tabBarController.tabBar.items[2];
//             item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
//         }
//     }];

    PFQuery *expiredPostNumberQuery = [PFQuery queryWithClassName:@"Post"];
    [expiredPostNumberQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [expiredPostNumberQuery  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects){
            int total = 0;
            for (SpreePost *post in objects){
                if (post.expired){
                    total += 1;
                }
            }
            UITabBarItem *item = self.tabBarController.tabBar.items[3];
            item.badgeValue = (total == 0 ) ? nil : [NSString stringWithFormat:@"%d", total];
        }
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [NSObject cancelPreviousPerformRequestsWithTarget:coachMarksView selector:@selector(start) object:nil];
}

-(void)addCoachMarks{
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{self.view.frame.size.width -45, 25},{35, 35}}],
                                @"caption": @"Post something on Spree!"
                                }
                            ];
    coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.tabBarController.view.bounds coachMarks:coachMarks];
    [self.tabBarController.view addSubview:coachMarksView];
    coachMarksView.maskColor = [UIColor colorWithWhite:1 alpha:.95];
    coachMarksView.lblCaption.textColor = [UIColor spreeBabyBlue];
    coachMarksView.lblCaption.font = [UIFont fontWithName:@"EuphemiaUCAS-Bold" size:24];
}


- (void)setupRefreshControl
{
    // TODO: Programmatically inserting a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // Setup the loading view, which will hold the moving graphics
    self.refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshLoadingView.backgroundColor = [UIColor clearColor];
    
    // Setup the color view, which will display the rainbowed background
    self.refreshColorView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    self.refreshColorView.alpha = 0.30;
    
    // Create the graphic image views
    CGRect refreshBounds = self.refreshControl.bounds;
//    self.compass_background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass_background.png"]];
    self.compass_spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spreeRefresh"]];
    self.compass_spinner.frame = CGRectMake((refreshBounds.size.width/2.0)-15, 0, 30, refreshBounds.size.height);
    self.compass_spinner.contentMode = UIViewContentModeScaleAspectFit;

    
    
    // Add the graphics to the loading view
    [self.refreshLoadingView addSubview:self.compass_background];
    [self.refreshLoadingView addSubview:self.compass_spinner];
    
    // Clip so the graphics don't stick out
    self.refreshLoadingView.clipsToBounds = YES;

    
    // Hide the original spinner icon
    self.refreshControl.tintColor = [UIColor clearColor];
    
    // Add the loading and colors views to our refresh control
    [self.refreshControl addSubview:self.refreshColorView];
    [self.refreshControl addSubview:self.refreshLoadingView];
    
    // Initalize flags
    self.isRefreshIconsOverlap = NO;
    self.isRefreshAnimating = NO;
    
    // When activated, invoke our refresh function
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
    // Get the current size of the refresh controller
    CGRect refreshBounds = self.refreshControl.bounds;
    
    // Distance the table has been pulled >= 0
    CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
    
    // Half the width of the table
    CGFloat midX = self.tableView.frame.size.width / 2.0;
    
    // Calculate the width and height of our graphics
    CGFloat compassHeight = self.compass_background.bounds.size.height;
    CGFloat compassHeightHalf = compassHeight / 2.0;
    
    CGFloat compassWidth = self.compass_background.bounds.size.width;
    CGFloat compassWidthHalf = compassWidth / 2.0;
    
    CGFloat spinnerHeight = self.compass_spinner.bounds.size.height;
    CGFloat spinnerHeightHalf = spinnerHeight / 2.0;
    
    CGFloat spinnerWidth = self.compass_spinner.bounds.size.width;
    CGFloat spinnerWidthHalf = spinnerWidth / 2.0;
    
    // Calculate the pull ratio, between 0.0-1.0
    CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), 100.0) / 100.0;
    
    // Set the Y coord of the graphics, based on pull distance
    CGFloat compassY = pullDistance / 2.0 - compassHeightHalf;
    CGFloat spinnerY = pullDistance / 2.0 - spinnerHeightHalf;
    
    // Calculate the X coord of the graphics, adjust based on pull ratio
    CGFloat compassX = (midX + compassWidthHalf) - (compassWidth * pullRatio);
    CGFloat spinnerX = (midX - spinnerWidth - spinnerWidthHalf) + (spinnerWidth * pullRatio);
    
    // When the compass and spinner overlap, keep them together
    if (fabsf(compassX - spinnerX) < 1.0) {
        self.isRefreshIconsOverlap = YES;
    }
    
    // If the graphics have overlapped or we are refreshing, keep them together
    if (self.isRefreshIconsOverlap || self.refreshControl.isRefreshing) {
        compassX = midX - compassWidthHalf;
        spinnerX = midX - spinnerWidthHalf;
    }
    
    // Set the graphic's frames
    CGRect compassFrame = self.compass_background.frame;
    compassFrame.origin.x = compassX;
    compassFrame.origin.y = compassY;
    
    CGRect spinnerFrame = self.compass_spinner.frame;
    spinnerFrame.origin.x = spinnerX;
    spinnerFrame.origin.y = spinnerY;
    
    self.compass_background.frame = compassFrame;
    self.compass_spinner.frame = spinnerFrame;
    
    // Set the encompassing view's frames
    refreshBounds.size.height = pullDistance;
    
    self.refreshColorView.frame = refreshBounds;
    self.refreshLoadingView.frame = refreshBounds;
    */
    // If we're refreshing and the animation is not playing, then play the animation
    if (self.refreshControl.isRefreshing && !self.isRefreshAnimating) {
        [self animateRefreshView];
    }
}

-(void)forcedRefresh {
    [self.refreshControl beginRefreshing];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self.tableView reloadData];
}


- (void)animateRefreshView
{
    // Background color to loop through for our color view
    NSArray *colorArray = @[[UIColor spreeRed],[UIColor spreeDarkBlue],[UIColor spreeLightYellow],[UIColor spreeBabyBlue],[UIColor spreeDarkYellow]];
    static int colorIndex = 0;
    
    // Flag that we are animating
    self.isRefreshAnimating = YES;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                         [self.compass_spinner setTransform:CGAffineTransformRotate(self.compass_spinner.transform, M_PI_2)];
                         // Change the background color
                         self.refreshColorView.backgroundColor = [colorArray objectAtIndex:colorIndex];
                         colorIndex = (colorIndex + 1) % colorArray.count;
                     }
                     completion:^(BOOL finished) {
                         
                         // If still refreshing, keep spinning, else reset
                         if (self.refreshControl.isRefreshing) {
                             [self animateRefreshView];
                         }else{
                             [self resetAnimation];
                         }
                     }];
}

- (void)resetAnimation
{
    // Reset our flags and background color

    self.isRefreshAnimating = NO;
    self.isRefreshIconsOverlap = NO;
    self.refreshColorView.backgroundColor = [UIColor clearColor];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _postTypeArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
    if ([[_postTypeArray objectAtIndex:indexPath.row] isEqualToString:@"Free"]){
        PFQuery *query = [PFQuery queryWithClassName:@"Post"];
        PFQuery *query2 = [PFQuery queryWithClassName:@"Post"];
        [query2 whereKeyDoesNotExist:@"price"];
        [query whereKey:@"price" equalTo:[NSNumber numberWithFloat:0]];
        [query whereKey:@"expired" equalTo:[NSNumber numberWithBool:NO]];
        [query whereKey:@"sold" equalTo:[NSNumber numberWithBool:NO]];
        [query whereKey:@"network" equalTo:[[PFUser currentUser] objectForKey:@"network"]];
        PFQuery *finalQuery = [PFQuery orQueryWithSubqueries:@[query,query2]];
        [finalQuery orderByDescending:@"updatedAt"];
        [finalQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            cell.numberLabel.text = [NSString stringWithFormat:@"0 Posts"];
            if (number) {
                NSLog(@"%@ %d", [_postTypeArray objectAtIndex:indexPath.row], number);
                cell.numberLabel.text = [NSString stringWithFormat:@"%@ Posts", [@(number)stringValue]];
                _pastPostNumber = number;
            }
            [self.refreshControl endRefreshing];
        }];
    } else {
        [postQuery whereKey:@"type" equalTo:[_postTypeArray objectAtIndex:indexPath.row]];
        [postQuery whereKey:@"expired" equalTo:[NSNumber numberWithBool:NO]];
        [postQuery whereKey:@"sold" equalTo:[NSNumber numberWithBool:NO]];
        [postQuery whereKey:@"network" equalTo:[[PFUser currentUser] objectForKey:@"network"]];

        [postQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            cell.numberLabel.text = [NSString stringWithFormat:@"0 Posts"];
            if (number) {
                NSLog(@"%@ %d", [_postTypeArray objectAtIndex:indexPath.row], number);
                [self.refreshControl endRefreshing];
                cell.numberLabel.text = [NSString stringWithFormat:@"%@ Posts", [@(number)stringValue]];
                _pastPostNumber = number;
            }
        }];
    }
    cell.titleLabel.text = [_postTypeArray objectAtIndex:indexPath.row];
    
    if ([[_postTypeArray objectAtIndex:indexPath.row] isEqualToString: @"Books"]){
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[iconColorArray objectAtIndex:indexPath.row] highlightedColor:[UIColor spreeLightYellow]];
        cell.detailImage.image = [UIImage imageNamed:@"BookTypeIconSmall"];
        cell.iconBackground.backgroundColor = [iconColorArray objectAtIndex:indexPath.row];
    } else if ([[_postTypeArray objectAtIndex:indexPath.row] isEqualToString: @"Tickets"]){
        cell.detailImage.image = [UIImage imageNamed:@"TicketTypeIconSmall"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[iconColorArray objectAtIndex:indexPath.row] highlightedColor:[UIColor spreeLightYellow]];
        cell.iconBackground.backgroundColor = [iconColorArray objectAtIndex:indexPath.row];
    } else if ([[_postTypeArray objectAtIndex:indexPath.row] isEqualToString: @"Electronics"]){
        cell.detailImage.image = [UIImage imageNamed:@"ElectronicsTypeIconSmall"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[iconColorArray objectAtIndex:indexPath.row] highlightedColor:[UIColor spreeLightYellow]];
        cell.iconBackground.backgroundColor = [iconColorArray objectAtIndex:indexPath.row];
    } else if ([[_postTypeArray objectAtIndex:indexPath.row] isEqualToString: @"Free"]){
        cell.detailImage.image = [UIImage imageNamed:@"freeGraphic"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[iconColorArray objectAtIndex:indexPath.row] highlightedColor:[UIColor spreeLightYellow]];
        cell.iconBackground.backgroundColor = [iconColorArray objectAtIndex:indexPath.row];
    }
    else if ([[_postTypeArray objectAtIndex:indexPath.row] isEqualToString: @"Furniture"]){
        cell.detailImage.image = [UIImage imageNamed:@"furnitureCellIconWhite"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[iconColorArray objectAtIndex:indexPath.row] highlightedColor:[UIColor spreeLightYellow]];
        cell.iconBackground.backgroundColor = [iconColorArray objectAtIndex:indexPath.row];
    } else if ([[_postTypeArray objectAtIndex:indexPath.row] isEqualToString: @"Clothing"]){
        cell.detailImage.image = [UIImage imageNamed:@"clothingCellIconWhite"];
        cell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[iconColorArray objectAtIndex:indexPath.row] highlightedColor:[UIColor spreeLightYellow]];
        cell.iconBackground.backgroundColor = [iconColorArray objectAtIndex:indexPath.row];
    } else if ([[_postTypeArray objectAtIndex:indexPath.row] isEqualToString: @"Tasks"]){
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
        sprintCell.accessoryView = [MSCellAccessory accessoryWithType: FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeBabyBlue] highlightedColor:[UIColor spreeLightYellow]];
        return sprintCell;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"DisplayPosts" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"DisplayPosts"]){
        PostTypeTableViewCell *selectedCell = (PostTypeTableViewCell*)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
        PostTypeTableViewController *destinationViewController = segue.destinationViewController;
        if ([[self.postTypeArray objectAtIndex:self.tableView.indexPathForSelectedRow.row] isEqualToString:@"Tasks"])
            destinationViewController.postType = @"Tasks";
        else
            destinationViewController.postType = selectedCell.titleLabel.text;
        
        
    }
    
}



- (IBAction)newPostButtonPressed:(id)sender {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    NewPostViewController *newPostViewController = [storyboard instantiateViewControllerWithIdentifier:@"NewPostViewController"];
//    [self.navigationController presentViewController:newPostViewController animated:YES completion:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewPostTypeSelectionViewController *newPostSelectTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"NewPostSelectTypeViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: newPostSelectTypeViewController];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}



@end
