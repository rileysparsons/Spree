//
//  PostCollectionViewController.m
//  
//
//  Created by Riley Steele Parsons on 3/6/16.
//
//

#import "PostCollectionViewController.h"
#import "PostCollectionViewCell.h"
#import "RequestLocationBackgroundView.h"
#import "PostDetailTableViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

#define CELL_IDENTIFIER @"WaterfallCell"
#define HEADER_IDENTIFIER @"WaterfallHeader"
#define FOOTER_IDENTIFIER @"WaterfallFooter"

@interface PostCollectionViewController ()

@property (nonatomic, strong) NSArray *cellSizes;
@property (nonatomic, strong) NSArray *posts;
@property (retain, nonatomic) UIBarButtonItem *composeButton;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIView *errorBackgroundView;
@property (nonatomic, strong) UIView *emptyStateBackgroundView;
@property (nonatomic, strong) RequestLocationBackgroundView *requestLocationBackgroundView;
@property (nonatomic, strong) UIButton *requestLocationServicesButton;
@property (nonatomic, strong) UILabel *errorMessageLabel;
@property MBProgressHUD *progressHUD;

@end

@implementation PostCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)setUpCollectionView {
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerHeight = 15;
    layout.footerHeight = 10;
    layout.minimumColumnSpacing = 20;
    layout.minimumInteritemSpacing = 30;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:self.collectionView.frame];
    [self.collectionView addSubview:self.refreshControl];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PostCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    
//    [self.collectionView registerClass:[PostCollectionViewCell class]
//        forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
//               withReuseIdentifier:HEADER_IDENTIFIER];
//    [self.collectionView registerClass:[PostCollectionViewCell class]
//        forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
//               withReuseIdentifier:FOOTER_IDENTIFIER];
}

- (NSArray *)cellSizes {
    if (!_cellSizes) {
        _cellSizes = @[
                       [NSValue valueWithCGSize:CGSizeMake(400, 550)],
                       // Can add various sizes for Waterfall effect, be sure to change the modulus value in delegate method below for size to match
                       ];
    }
    return _cellSizes;
}

-(void)bindViewModel{

    NSLog(@"%@", self.viewModel);
    
    @weakify(self)

    self.refreshControl.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [self.viewModel.refreshPosts execute:nil];
    }];
    
    RAC(self, posts) = RACObserve(self.viewModel, posts);
    
    [[RACObserve(self, posts) deliverOnMainThread]
     subscribeNext:^(id x) {
         @strongify(self)
         [self.collectionView reloadData];
         [self.refreshControl endRefreshing];
     }];
    

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

    
    [[RACSignal combineLatest:@[RACObserve(self.viewModel, shouldHidePosts), RACObserve(self.viewModel, promptForLocation), RACObserve(self.viewModel, posts)]] subscribeNext:^(id x) {
        if (self.viewModel.promptForLocation){
            self.collectionView.backgroundView = self.requestLocationBackgroundView;
        } else {
            if (self.viewModel.shouldHidePosts){
                self.collectionView.backgroundView = self.errorBackgroundView;
            } else {
                if (self.viewModel.posts.count == 0){
                    self.collectionView.backgroundView = self.emptyStateBackgroundView;
                } else {
                    self.collectionView.backgroundView = nil;
                }
            }
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpCollectionView];
    [self userInterfaceSetup];
    [self bindViewModel];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.active = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.viewModel.active = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    self.collectionView.backgroundColor = [UIColor spreeOffWhite];
    
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

-(UIView *)errorBackgroundView{
    
    if (!_errorBackgroundView){
        _errorBackgroundView = [[[NSBundle mainBundle] loadNibNamed:@"LocationNotFoundView" owner:self options:nil] objectAtIndex:0];
        
        // Make my frame size match the size of the content view in the xib.
        CGRect newFrame = self.collectionView.frame;
        // 125 is the height of the scrolling view on the top
        // 48 is the height of the tab bar.
        newFrame.size.height = self.collectionView.frame.size.height-125-48;
        newFrame.origin.y = 125;
        
        _errorBackgroundView.frame = newFrame;
        
        [_errorBackgroundView updateConstraints];
    }
    
    return _errorBackgroundView;
}

-(UIView *)emptyStateBackgroundView{
    
    if (!_emptyStateBackgroundView){
        _emptyStateBackgroundView = [[[NSBundle mainBundle] loadNibNamed:@"PostsNotFoundView" owner:self options:nil] objectAtIndex:0];
        
        // Make my frame size match the size of the content view in the xib.
        CGRect newFrame = self.collectionView.frame;
        // 125 is the height of the scrolling view on the top
        // 48 is the height of the tab bar.
        newFrame.size.height = self.collectionView.frame.size.height-125-48;
        newFrame.origin.y = 125;
        
        _emptyStateBackgroundView.frame = newFrame;
        
        [_emptyStateBackgroundView updateConstraints];
    }
    return _emptyStateBackgroundView;
}

-(RequestLocationBackgroundView *)requestLocationBackgroundView{
    
    if (!_requestLocationBackgroundView){
        _requestLocationBackgroundView = [[[NSBundle mainBundle] loadNibNamed:@"RequestLocationBackgroundView" owner:self options:nil] objectAtIndex:0];
        
        // Make my frame size match the size of the content view in the xib.
        CGRect newFrame = self.collectionView.frame;
        // 125 is the height of the scrolling view on the top
        // 48 is the height of the tab bar.
        newFrame.size.height = self.collectionView.frame.size.height-125-48;
        newFrame.origin.y = 125;
        
        _requestLocationBackgroundView.frame = newFrame;
        
        _requestLocationBackgroundView.authorizeLocationServicesButton.rac_command = self.viewModel.requestLocationServices;
        
        [_requestLocationBackgroundView updateConstraints];
    }
    return _requestLocationBackgroundView;
}


-(void)presentDetailViewControllerForPost:(SpreePost *)post {
    PostDetailTableViewController *postDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PostDetail"];
    
    [postDetailViewController initWithPost:post];
    
    [self.navigationController pushViewController:postDetailViewController animated:YES];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.posts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCollectionViewCell *cell =
    (PostCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                forIndexPath:indexPath];
    [cell bindViewModel:self.posts[indexPath.row]];
    NSLog(@"%@", self.posts);
    return cell;
}


#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellSizes[indexPath.item % 1] CGSizeValue];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel.postSelectedCommand execute:[self.posts objectAtIndex:indexPath.item]];
    return YES;
}


/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
