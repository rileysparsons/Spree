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
#import "RatingViewController.h"
#import "AppDelegate.h"
#import "AppConstant.h"
#import "PostDetailTableViewController.h"
#import "SelectPostTypeViewController.h"

@interface AllPostsTableViewController () {

}

@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *compass_background;
@property (nonatomic, strong) UIImageView *compass_spinner;
@property (assign) BOOL isRefreshIconsOverlap;
@property (assign) BOOL isRefreshAnimating;
@property (retain, nonatomic) UIBarButtonItem *composeButton;
@property (nonatomic, strong) PostDetailTableViewController *postDetailTableViewController;
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
        self.pullToRefreshEnabled = NO;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = self.tabBarController;
    
    [self setupRefreshControl];
    UIImage *image = [UIImage imageNamed:@"spreeTitleStylized.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.titleView.tintColor = [UIColor spreeDarkBlue];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"ReloadTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"PostMade" object:nil];

    self.navigationItem.rightBarButtonItems = @[self.composeButton];

    // Check if buyer needs to rate the seller
    PFQuery *query = [PFQuery queryWithClassName:@"RatingQueue"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query includeKey:@"rateUser"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            RatingViewController *ratingView = [self.storyboard instantiateViewControllerWithIdentifier:@"rating"];
            ratingView.ratingType = @"seller";
            ratingView.user = [object objectForKey:@"rateUser"];

            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:ratingView];
            [self presentViewController:navigationController animated:YES completion:NULL];

            // Delete from the queue
            [object deleteInBackground];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
    [query includeKey:PF_RECENT_LASTUSER];
    [query orderByDescending:PF_RECENT_UPDATEDACTION];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (objects)
         {
             int total = 0;
             for (PFObject *recent in objects)
             {
                 total += [recent[PF_RECENT_COUNTER] intValue];
             }
             UITabBarItem *item = self.tabBarController.tabBar.items[2];
             item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
         }
     }];
}

- (UIBarButtonItem *)composeButton {
    if (!_composeButton) {
        _composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCompose target: self action: @selector(NewPostBarButtonItemPressed:)];
        [_composeButton setTintColor:[UIColor spreeDarkBlue]];
    }
    return _composeButton;
}

- (void)delayedRefresh{
    NSLog(@"Delayed refresh called");
    [self performSelector:@selector(loadObjects) withObject:nil afterDelay:0.75f];
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
    [self.refreshControl addTarget:self action:@selector(loadObjects) forControlEvents:UIControlEventValueChanged];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.refreshControl.isRefreshing && !self.isRefreshAnimating) {
        [self animateRefreshView];
    }
}

- (void)resetAnimation
{
    // Reset our flags and background color
    
    self.isRefreshAnimating = NO;
    self.isRefreshIconsOverlap = NO;
    self.refreshColorView.backgroundColor = [UIColor clearColor];
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



#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    if (self.objects.count == 0){
        // Display a message when the table is empty
        messageLabel.text = @"No posts have been made in your area.\n\nYou can be the first!";
        messageLabel.textColor = [UIColor spreeDarkBlue];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"EuphemiaUCAS" size:20];
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else if (self.objects.count > 0 ){
        self.tableView.backgroundView.hidden = YES;
        NSLog(@"Objects did load");
    }
    NSLog(@"%lu", self.objects.count);
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}


- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"expired" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"sold" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"network" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"updatedAt"];
    NSLog(@"%@", [PFUser currentUser]);
    [query whereKey:@"network" equalTo:[[PFUser currentUser] objectForKey:@"network"]];
    [query includeKey:@"objectId"];
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark - Navigation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    self.postDetailTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PostDetail"];

    
    if ([indexPath row] > self.objects.count -1 ) {
        return;
    }
    [self.postDetailTableViewController setFields:[self fieldsForPostType:[[self objectAtIndexPath:indexPath]objectForKey:PF_POST_TYPE]]];
    NSLog(@"%@", [self fieldsForPostType:[[self objectAtIndexPath:indexPath]objectForKey:PF_POST_TYPE]]);
    [self.postDetailTableViewController setPost:(SpreePost *)[self objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:self.postDetailTableViewController animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)NewPostBarButtonItemPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:nil];
    SelectPostTypeViewController *selectPostTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectPostTypeViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: selectPostTypeViewController];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

// Detail View Setup

-(NSArray *)fieldsForPostType:(NSString *)type{
    NSMutableArray *fields = [NSMutableArray arrayWithArray:@[PF_POST_PHOTOARRAY, PF_POST_TITLE, PF_POST_DESCRIPTION, PF_POST_USER]];
    if ([type isEqualToString:POST_TYPE_BOOKS]){
        [fields insertObject:PF_POST_BOOKFORCLASS atIndex:3];
    } else if ([type isEqualToString:POST_TYPE_TICKETS]){
        [fields insertObject:PF_POST_DATEFOREVENT atIndex:3];
    } else if ([type isEqualToString:POST_TYPE_CLOTHING]){
        
    } else if ([type isEqualToString:POST_TYPE_FURNITURE]){
        
    } else if ([type isEqualToString:POST_TYPE_TASK]){
            // NEED TO ADD FIELDS
    }
    return fields;
}

@end
