//
//  PostTableViewController.m
//  
//
//  Created by Riley Steele Parsons on 3/20/15.
//
//

#import "PostTableViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import "CETableViewBindingHelper.h"
#import "SpreeViewModelServicesImpl.h"
#import "PostTableViewCell.h"
#import "PostingWorkflowViewModel.h"
#import "SpreePost.h"
#import "AppConstant.h"
#import "PostDetailTableViewController.h"
#import "BasePostingViewController.h"

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
@property (nonatomic, strong) UIView *emptyStateView;
@property (nonatomic, strong) UIButton *requestLocationServicesButton;
@property (nonatomic, strong) UILabel *errorMessageLabel;
@property MBProgressHUD *progressHUD;


@end


@implementation PostTableViewController

// TODO: Refresh control is faulty, reorganize the new post creation button, remove all Parse logic

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"ReloadTable" object:nil]
     subscribeNext:^(id x) {
         [self.viewModel.refreshPosts execute:nil];
     }];
    
     // Removes lines from showing with empty cells
    self.postsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor spreeOffWhite];
    [self.postsTableView addSubview:self.refreshControl];
    
    // Initializing the posts array
    self.posts = [[NSArray alloc] init];

    // The error view blocks the table view when location services are no longer enabled
    [self setupErrorView];
    
    [self setupEmptyStateView];
    
    // Binds the view model to the viewcontroller/view
    [self bindViewModel];
    
//    [self.viewModel.refreshPosts execute:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.active = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.viewModel.active = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // Unselect the selected row if any
    NSIndexPath*    selection = [self.postsTableView indexPathForSelectedRow];
    if (selection) {
        [self.postsTableView deselectRowAtIndexPath:selection animated:YES];
    }
}

-(void)bindViewModel{

    @weakify(self)
    self.refreshControl.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [self.viewModel.refreshPosts execute:nil];
    }];
    
    RAC(self, posts) = RACObserve(self.viewModel, posts);

    RAC(self.backgroundView, hidden) = [[RACObserve(self.viewModel, shouldHidePosts) not] deliverOnMainThread];

    
    RAC(self.emptyStateView, hidden) = [[RACObserve(self.viewModel, posts) map:^id(NSArray *posts) {
        if (posts.count > 0){
            return @YES;
        } else {
            return @NO;
        }
    }] deliverOnMainThread];

    
    [[RACObserve(self, posts) deliverOnMainThread]
     subscribeNext:^(id x) {
        @strongify(self)
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
        @strongify(self)
        [self presentDetailViewControllerForPost:post];
    }];
    

    [[RACObserve(self.viewModel, isLoadingPosts) deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self)
        self.progressHUD.labelText = @"Loading Posts...";
        if ([x boolValue]){
            [self.progressHUD show:NO];
        } else {
            [self.progressHUD hide:YES afterDelay:0.5];
        }
    }];
    
    [[RACObserve(self.viewModel, isFindingLocation) deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self)
        self.progressHUD.labelText = @"Finding Location...";
        if ([x boolValue]){
            [self.progressHUD show:YES];
        } else {
            [self.progressHUD hide:NO];
        }
    }];

}

#pragma mark - UI Setup

- (void)userInterfaceSetup {
    // Bar title
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *itemTypeDescription = @"Items";
    if (self.viewModel.queryParameters != nil && self.viewModel.queryParameters[@"type"] != nil) {
        itemTypeDescription = self.viewModel.queryParameters[@"type"];
    }
    titleLabel.text= [NSString stringWithFormat:@"%@ Near You",itemTypeDescription];
    titleLabel.textColor=[UIColor spreeOffBlack];
    titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size: 17.0];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=titleLabel;
    
    self.view.backgroundColor = [UIColor spreeOffWhite];
    self.postsTableView.backgroundColor = [UIColor spreeOffWhite];
    
    // For new post creation
    self.navigationItem.rightBarButtonItems = @[self.composeButton];
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.progressHUD];
}

- (UIBarButtonItem *)composeButton {
    if (!_composeButton) {
        _composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCompose target: self action: @selector(NewPostBarButtonItemPressed:)];
        [_composeButton setTintColor:[UIColor spreeDarkBlue]];
    }
    return _composeButton;
}

-(void)setupErrorView{

    self.backgroundView = [[[NSBundle mainBundle] loadNibNamed:@"LocationNotFoundView" owner:self options:nil] objectAtIndex:0];
    
    // Make my frame size match the size of the content view in the xib.
    CGRect newFrame = self.postsTableView.frame;
    // 125 is the height of the scrolling view on the top
    // 48 is the height of the tab bar.
    newFrame.size.height = self.postsTableView.frame.size.height-125-48;
    newFrame.origin.y = 125;
    
    self.backgroundView.frame = newFrame;
    
    [self.backgroundView updateConstraints];
    
    NSLog(@"background view frame: %f", self.backgroundView.frame.size.width);
    
    [self.postsTableView addSubview:self.backgroundView];
}

-(void)setupEmptyStateView{
    self.emptyStateView = [[[NSBundle mainBundle] loadNibNamed:@"PostsNotFoundView" owner:self options:nil] objectAtIndex:0];
    
    // Make my frame size match the size of the content view in the xib.
    CGRect newFrame = self.postsTableView.frame;
    // 125 is the height of the scrolling view on the top
    // 48 is the height of the tab bar.
    newFrame.size.height = self.postsTableView.frame.size.height-125-48;
    newFrame.origin.y = 125;
    
    self.emptyStateView.frame = newFrame;
    
    [self.emptyStateView updateConstraints];
    
    [self.postsTableView insertSubview:self.emptyStateView belowSubview:self.backgroundView];

}

#pragma mark - Navigation

- (void)NewPostBarButtonItemPressed:(id)sender {
    
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    NSLog(@"%@", viewModelServices);
    PostingWorkflowViewModel *postingWorkflowViewModel = [[PostingWorkflowViewModel alloc] initWithServices:viewModelServices];
    [[postingWorkflowViewModel.endPostingWorkflowCommand.executionSignals switchToLatest] subscribeNext:^(id x) {
        [self.viewModel.refreshPosts execute:nil];
    }];
    BasePostingViewController *basePostingViewController = [[BasePostingViewController alloc] initWithViewModel:postingWorkflowViewModel];
     NSLog(@"%@", basePostingViewController);
    UINavigationController *postingWorkflowNavigationController = [[UINavigationController alloc] initWithRootViewController:basePostingViewController];
    
    [self.navigationController presentViewController:postingWorkflowNavigationController animated:YES completion:nil];
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
        
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, whiteView.frame.size.width, 35)];
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
