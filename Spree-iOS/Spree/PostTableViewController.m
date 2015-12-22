//
//  PostTableViewController.m
//  
//
//  Created by Riley Steele Parsons on 3/20/15.
//
//

#import "PostTableViewController.h"
#import "RTWalkthroughPageViewController.h"
#import "RTWalkthroughViewController.h"
#import "PostTableViewCell.h"
#import "SpreePost.h"
#import "RatingViewController.h"
#import "AppDelegate.h"
#import "AppConstant.h"
#import "PostDetailTableViewController.h"
#import "SelectPostTypeViewController.h"
#import "ResultsTableViewController.h"
#import "SpreeUtility.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface PostTableViewController () {

}

@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *compass_background;
@property (nonatomic, strong) UIImageView *compass_spinner;
@property UILabel *headerLabel;
@property (assign) BOOL isRefreshIconsOverlap;
@property (assign) BOOL isRefreshAnimating;
@property (retain, nonatomic) UIBarButtonItem *composeButton;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *requestLocationServicesButton;
@property (nonatomic, strong) UILabel *errorMessageLabel;


@end


@implementation PostTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = self.tabBarController;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setupRefreshControl];
    
    // Bar title
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text= @"CAMPUS";
    titleLabel.textColor=[UIColor spreeOffBlack];
    titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size: 17.0];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=titleLabel;
    
    self.view.backgroundColor = [UIColor spreeOffWhite];
    self.tableView.backgroundColor = [UIColor spreeOffWhite];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"ReloadTable" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"PostMade" object:nil];

    self.navigationItem.rightBarButtonItems = @[self.composeButton];
    
    self.postDetailTableViewController = [[PostDetailTableViewController alloc] init];
    
    // Check if buyer needs to rate the seller
    PFQuery *query = [PFQuery queryWithClassName:@"RatingQueue"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query includeKey:@"rateUser"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            RatingViewController *ratingView = [self.storyboard instantiateViewControllerWithIdentifier:@"rating"];
            ratingView.ratingType = @"buyer";
            ratingView.user = [object objectForKey:@"rateUser"];
            ratingView.post = [object objectForKey:@"post"];

            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:ratingView];
            [self presentViewController:navigationController animated:YES completion:NULL];

            // Delete from the queue
            [object deleteInBackground];
        } else {
            NSLog(@"No ratings required");
        }
    }];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.posts = [[NSArray alloc] init];

    [self setupErrorView];
    
    [self bindViewModel];

    
}

-(void)bindViewModel{
    self.refreshControl.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [self.viewModel.refreshPosts execute:nil];
    }];;
    
    RAC(self, posts) = RACObserve(self.viewModel, posts);
    
    [[RACObserve(self, posts) deliverOnMainThread]
     subscribeNext:^(id x) {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
    
    RAC(self.backgroundView, hidden) = RACObserve(self.viewModel, locationServicesAuthorized);

    RAC(self.requestLocationServicesButton, hidden) = RACObserve(self.viewModel, locationServicesAuthorized);
    
    [RACObserve(self.viewModel, locationServicesAuthorized) subscribeNext:^(id x) {
        NSLog(@"auth %@", x);
    }];

    self.requestLocationServicesButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [self.viewModel.requestLocationServices execute:nil];
    }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.active = YES;
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

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.viewModel.active = NO;
}

- (UIBarButtonItem *)composeButton {
    if (!_composeButton) {
        _composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCompose target: self action: @selector(NewPostBarButtonItemPressed:)];
        [_composeButton setTintColor:[UIColor spreeDarkBlue]];
    }
    return _composeButton;
}

- (void)setupRefreshControl {
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
    // Replaced with call to view model
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.refreshControl.isRefreshing && !self.isRefreshAnimating) {
        [self animateRefreshView];
    }
}

- (void)resetAnimation
{
    // Reset our flags and background color
    [UIView animateWithDuration:0.5f animations:^{
        [self.compass_spinner setTransform:CGAffineTransformIdentity];
        
    }];
    
    self.isRefreshAnimating = NO;
    self.isRefreshIconsOverlap = NO;
    self.refreshColorView.backgroundColor = [UIColor clearColor];
}

- (void)animateRefreshView
{

    
    // Flag that we are animating
    self.isRefreshAnimating = YES;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                         [self.compass_spinner setTransform:CGAffineTransformRotate(self.compass_spinner.transform, M_PI_2)];
                         // Change the background color
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

//- (void)objectsDidLoad:(NSError *)error {
//    [super objectsDidLoad:error];
//    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
//    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    if (self.objects.count == 0){
//        // Display a message when the table is empty
//        messageLabel.text = @"No posts found at your school.\n\nPost the first!";
//        messageLabel.textColor = [UIColor spreeDarkBlue];
//        messageLabel.numberOfLines = 0;
//        messageLabel.textAlignment = NSTextAlignmentCenter;
//        messageLabel.font = [UIFont fontWithName:@"Lato-Regular" size:20];
//        [messageLabel sizeToFit];
//        self.tableView.backgroundView = messageLabel;
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    } else if (self.objects.count > 0 ){
//        self.tableView.backgroundView.hidden = YES;
//        NSLog(@"Objects did load");
//    }
//    // This method is called every time objects are loaded from Parse via the PFQuery
//}

//- (void)objectsWillLoad {
//    [super objectsWillLoad];
//    
//    // This method is called before a PFQuery is fired to get more objects
//}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"posts in count %@", self.posts);
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
        SpreePost *post = (SpreePost *)self.posts[indexPath.row];
        NSLog(@"POST %@", self.posts[indexPath.row]);
        cell.postTitleLabel.text = post.title;
        if (post.price == 0 || [post.price  isEqual: @(0)]){
            cell.priceLabel.text = @"Free";
        } else {
            int priceFloat = [post.price intValue];
            NSString *price = [NSString stringWithFormat:@"$%d", priceFloat];
            cell.priceLabel.text = price;
        }
        
        if (post.photoArray.count != 0){
            PFFile *imageFile = (PFFile *)[post.photoArray objectAtIndex:0];
            cell.postImageView.file = imageFile;
            [cell.postImageView loadInBackground];
        } else {
            cell.imageBackgroundView.backgroundColor = [UIColor spreeOffBlack];
            [post.typePointer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
                if ([post.typePointer[@"type"] isEqualToString: @"Tasks & Services"]){
                    cell.placeholderIconView.image = [UIImage imageNamed:@"tasksAndServicesThumbnail"];
                }
            }];
        }
        
        cell.descriptionLabel.text = [NSString stringWithFormat:@"\u201C%@\u201D", post.userDescription];
        
        NSDate *dateCreatedGMT = [post createdAt];
        NSTimeInterval timeSince = dateCreatedGMT.timeIntervalSinceNow;
        double timeSinceInDays = timeSince/60/60/24*(-1);
        if (timeSinceInDays > 1){
            double roundedValue = round(timeSinceInDays);
            int roundedInteger = (int)roundedValue;
            NSNumber *numberSince = [NSNumber numberWithInt:roundedInteger];
            NSString *timeSincePost = [numberSince stringValue];
            NSString *timeWithUnits = [NSString stringWithFormat:(@"%@ days ago"), timeSincePost];
            cell.postTimeLabel.text = timeWithUnits;
        } else {
            double timeSinceInHours = timeSinceInDays*24;
            double timeSinceInMinutes = timeSinceInHours*60;
            if (timeSinceInHours > 1){
                double timeSinceInHoursRounded = round(timeSinceInHours);
                int roundedInteger = (int)timeSinceInHoursRounded;
                NSNumber *numberSince = [NSNumber numberWithInt:roundedInteger];
                NSString *timeSincePost = [numberSince stringValue];
                NSString *timeWithUnits = [NSString stringWithFormat:(@"%@ hours ago"), timeSincePost];
                cell.postTimeLabel.text = timeWithUnits;
            } else if (timeSinceInMinutes > 1){
                int roundedInteger = (int)timeSinceInMinutes;
                NSNumber *numberSince = [NSNumber numberWithInt:roundedInteger];
                NSString *timeSincePost = [numberSince stringValue];
                NSString *timeWithUnits = [NSString stringWithFormat:(@"%@ minutes ago"), timeSincePost];
                cell.postTimeLabel.text = timeWithUnits;
            } else {
                NSString *message = @"Just now";
                cell.postTimeLabel.text = message;
            }
        }
        return cell;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

#pragma mark - Navigation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//    if ([indexPath row] > self.objects.count -1 ) {
//        return;
//    } else {
//        SpreePost *selectedPost = self.objects[indexPath.row];
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//        self.postDetailTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostDetail"];
//        NSLog(@"%@", self.storyboard);
//        [self.postDetailTableViewController initWithPost:selectedPost];
//        [self.navigationController pushViewController:self.postDetailTableViewController animated:YES];
//        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
    
}

- (void)NewPostBarButtonItemPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:nil];
    SelectPostTypeViewController *selectPostTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectPostTypeViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: selectPostTypeViewController];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 35)];
        UIColor *typeBackgroundColor = [UIColor spreeOffWhite];
        
        // Background color
        headerView.backgroundColor = typeBackgroundColor;
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 35)];
        whiteView.backgroundColor = [UIColor spreeOffWhite];
        [headerView addSubview:whiteView];
        
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, whiteView.frame.size.width, 35
                                                                         )];
        self.headerLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16];
        self.headerLabel.textColor = [UIColor spreeOffBlack];
        
        if (![SpreeUtility userInDemoMode]){
        PFQuery *userQuery = [PFUser query];
            [userQuery includeKey:@"campus"];
            [userQuery getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *user, NSError *error){
                NSLog(@"%@", user);
                self.headerLabel.text = [NSString stringWithFormat:@"Recent Posts at %@", user[@"campus"][@"campusName"]];
                [self.headerLabel setNeedsDisplay];
                
            }];
        } else {
            self.headerLabel.text = @"Examples of Posts on Spree";
        }
        [whiteView addSubview:self.headerLabel];
        return headerView;
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0)
        return 35;
    
    return 0;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath{
    PFTableViewCell *loadMore  = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadMore"];
    loadMore.textLabel.textColor = [UIColor spreeOffBlack];
    loadMore.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:20.0];
    loadMore.backgroundColor = [UIColor spreeOffWhite];
    loadMore.textLabel.text = @"See more posts...";
    return loadMore;

}


-(PFQuery *)addQueryParameters:(NSDictionary *)parameters toQuery:(PFQuery *)query{
    
    NSLog(@"%@", parameters);
    
    if (parameters && query){
        for (id parameter in parameters){
            for (id key in parameter){
                NSLog(@"%@, %@", key,parameter[key]);
                
                [query whereKey:key equalTo:parameter[key]];
//                for (id constraint in parameter[key]){
//                    NSLog(@"Constraint %@", constraint);
//                    if ([constraint isEqualToString: @"__type"]){
//                        if ([parameter[key][constraint] isEqualToString:@"Pointer"]){
//                            PFQuery *pointerQuery = [PFQuery queryWithClassName:parameter[@"className"]];
//                            [pointerQuery getObjectInBackgroundWithId:parameter[@"objectId"] block:^(PFObject *object, NSError *error){
//                                if (!error){
//                                    if (object)
//                                        [query whereKey:key equalTo:object];
//                                } else {
//                                    NSLog(@"%@",error);
//                                }
//                            }];
//                        }
//                    }
//                }
            }
        }
    }
    return query;
}

-(void)setupErrorView{
    self.backgroundView = [[UIVisualEffectView alloc] initWithFrame:self.tableView.frame];
    self.backgroundView.backgroundColor = [UIColor spreeOffBlack];
    [self.tableView addSubview:self.backgroundView];
    
    self.requestLocationServicesButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.backgroundView.frame.size.height/2, self.backgroundView.frame.size.width-20, 10)];
    [self.requestLocationServicesButton setTitle:@"Approve Location Services" forState:UIControlStateNormal];
    [self.requestLocationServicesButton setTitleColor:[UIColor spreeOffWhite] forState:UIControlStateNormal];

    self.errorMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.requestLocationServicesButton.frame.origin.x, self.requestLocationServicesButton.frame.origin.y-50, self.requestLocationServicesButton.frame.size.width, 60)];
    self.errorMessageLabel.textColor = [UIColor spreeOffWhite];
    
    
    [self.backgroundView addSubview:self.errorMessageLabel];
    [self.backgroundView addSubview:self.requestLocationServicesButton];
}

@end
