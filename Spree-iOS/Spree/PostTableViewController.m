//
//  PostTableViewController.m
//  
//
//  Created by Riley Steele Parsons on 3/20/15.
//
//

#import "PostTableViewController.h"

#import "CETableViewBindingHelper.h"
#import "PostTableViewCell.h"
#import "SpreePost.h"
#import "AppConstant.h"
#import "PostDetailTableViewController.h"
#import "SelectPostTypeViewController.h"

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

// TODO: Refresh control is faulty, reorganize the new post creation button, remove all Parse logic

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Refresh control
    [self setupRefreshControl];
    
    // Basic UI setup
    [self userInterfaceSetup];
    
    // Initialize detail table view controller. Pushed when cells are selected.
    self.postDetailTableViewController = [[PostDetailTableViewController alloc] init];
    
    /* Old Parse logic. Checks if buyer needs to rate the seller.
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
    */
    
     // Removes lines from showing with empty cells
    self.postsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   
    // Initializing the posts array
    self.posts = [[NSArray alloc] init];

    // The error view blocks the table view when location services are no longer enabled
    [self setupErrorView];
    
    // Binds the view model to the viewcontroller/view
    [self bindViewModel];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.active = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.viewModel.active = NO;
}

-(void)bindViewModel{

    self.refreshControl.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [self.viewModel.refreshPosts execute:nil];
    }];
    
    RAC(self, posts) = RACObserve(self.viewModel, posts);

    RAC(self.backgroundView, hidden) = [RACObserve(self.viewModel, shouldHidePosts) not];
    
    [[RACObserve(self, posts) deliverOnMainThread]
     subscribeNext:^(id x) {
        [self.postsTableView reloadData];
        [self.refreshControl endRefreshing];
    }];
    
    // Helper that abstracts all the UITableView logic and delegation away from the view controller using RAC
    UINib *nib = [UINib nibWithNibName:@"PostTableViewCell" bundle:nil];
    [CETableViewBindingHelper bindingHelperForTableView:self.postsTableView
                                           sourceSignal:RACObserve(self.viewModel, posts)
                                       selectionCommand:self.viewModel.postSelectedCommand
                                           templateCell:nib];
    
    
    // Pushes the detailViewController for post when cell is selected
    [[self.viewModel.postSelectedCommand.executionSignals switchToLatest] subscribeNext:^(SpreePost* post) {
        [self presentDetailViewControllerForPost:post];
    }];
}

#pragma mark - UI Setup

- (void)userInterfaceSetup {
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
    self.postsTableView.backgroundColor = [UIColor spreeOffWhite];
    
    // For new post creation
    self.navigationItem.rightBarButtonItems = @[self.composeButton];
}

- (UIBarButtonItem *)composeButton {
    if (!_composeButton) {
        _composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCompose target: self action: @selector(NewPostBarButtonItemPressed:)];
        [_composeButton setTintColor:[UIColor spreeDarkBlue]];
    }
    return _composeButton;
}

-(void)setupErrorView{
    self.backgroundView = [[UIVisualEffectView alloc] initWithFrame:self.postsTableView.frame];
    self.backgroundView.backgroundColor = [UIColor spreeOffBlack];
    [self.postsTableView addSubview:self.backgroundView];
    
    self.requestLocationServicesButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.backgroundView.frame.size.height/2, self.backgroundView.frame.size.width-20, 10)];
    [self.requestLocationServicesButton setTitle:@"Approve Location Services" forState:UIControlStateNormal];
    [self.requestLocationServicesButton setTitleColor:[UIColor spreeOffWhite] forState:UIControlStateNormal];

    self.errorMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.requestLocationServicesButton.frame.origin.x, self.requestLocationServicesButton.frame.origin.y-50, self.requestLocationServicesButton.frame.size.width, 60)];
    self.errorMessageLabel.textColor = [UIColor spreeOffWhite];
    
    
    [self.backgroundView addSubview:self.errorMessageLabel];
    [self.backgroundView addSubview:self.requestLocationServicesButton];
}

- (void)setupRefreshControl {

    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.postsTableView addSubview: self.refreshControl];
    
    // Setup the loading view, which will hold the moving graphics
    self.refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshLoadingView.backgroundColor = [UIColor clearColor];
    
    // Setup the color view, which will display the rainbowed background
    self.refreshColorView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    self.refreshColorView.alpha = 0.30;
    
    // Create the graphic image views
    CGRect refreshBounds = self.refreshControl.bounds;
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


#pragma mark - Navigation

- (void)NewPostBarButtonItemPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:nil];
    SelectPostTypeViewController *selectPostTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectPostTypeViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: selectPostTypeViewController];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

-(void)presentDetailViewControllerForPost:(SpreePost *)post {
    PostDetailTableViewController *postDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PostDetail"];
    
    [postDetailViewController initWithPost:post];
    
    [self.navigationController pushViewController:postDetailViewController animated:YES];
}

#pragma mark - Table View UI

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.postsTableView.frame.size.width, 35)];
        UIColor *typeBackgroundColor = [UIColor spreeOffWhite];
        
        // Background color
        headerView.backgroundColor = typeBackgroundColor;
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.postsTableView.bounds.size.width, 35)];
        whiteView.backgroundColor = [UIColor spreeOffWhite];
        [headerView addSubview:whiteView];
        
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, whiteView.frame.size.width, 35
                                                                         )];
        self.headerLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16];
        self.headerLabel.textColor = [UIColor spreeOffBlack];
        
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






@end
