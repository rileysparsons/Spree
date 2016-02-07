//
//  SelectPostTypeViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/28/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SelectPostTypeViewController.h"
#import "CETableViewBindingHelper.h"
#import "PostTypeSelectionTableViewCell.h"
#import "SelectPostSubTypeViewController.h"
#import "SpreePost.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <MMPReactiveCoreLocation/MMPReactiveCoreLocation.h>
#import "PostingWorkflowViewModel.h"
#import "SpreeUtility.h"
#import "SpreeMarketManager.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <MSCellAccessory/MSCellAccessory.h>

typedef enum : NSUInteger {
    kAuthorizeLocationServicesAlert,
    kMarketUnavailableAlert
} AlertViewTag;

@interface SelectPostTypeViewController () <UIAlertViewDelegate>

@property NSArray *postTypes;

@end

@implementation SelectPostTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted){
        UIAlertView *locationAlert =  [[UIAlertView alloc] initWithTitle:@"Location Unavailable" message:@"To post something to Spree you must authorize the use of your location through your phone's settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
       locationAlert.tag = kAuthorizeLocationServicesAlert;
        [locationAlert show];
        
    } else {
        [[[MMPReactiveCoreLocation service] location] subscribeNext:^(id x) {
            if (![[SpreeMarketManager sharedManager] writeRegionFromLocation:x]){
                UIAlertView *noMarketAvailableAlert =  [[UIAlertView alloc] initWithTitle:@"Posting unavailable in this area" message:@"Posting on spree is only available in select locations" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                
                noMarketAvailableAlert.tag = kAuthorizeLocationServicesAlert;
                [noMarketAvailableAlert show];
            }
        }];
    }
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor spreeOffWhite];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = [self titleLabel];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    cancel.backgroundColor = [UIColor clearColor];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(dismissViewControllerAnimated:completion:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:cancel]];
    
    NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"SelectPostTypeHeaderView" owner:self options:nil];
    for(id currentObject in nibFiles){
        if ([currentObject isKindOfClass:[UIView class]]){
            self.header = currentObject;
            break;
        }
    }
    [self.header setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    [self.header layoutSubviews];
    self.tableView.tableHeaderView = self.header;
    
    [self bindViewModel];
}

- (void)bindViewModel {
    RAC(self, postTypes) = RACObserve(self.viewModel, postTypes);
    
    // Helper that abstracts all the UITableView logic and delegation away from the view controller using RAC
    UINib *nib = [UINib nibWithNibName:@"PostTypeSelectionTableViewCell" bundle:nil];
    [CETableViewBindingHelper bindingHelperForTableView:self.tableView
                                           sourceSignal:RACObserve(self.viewModel, postTypes)
                                       selectionCommand:self.viewModel.typeSelectedCommand
                                           templateCell:nib];
    

    // Pushes the detailViewController for post when cell is selected
    [[self.viewModel.typeSelectedCommand.executionSignals switchToLatest] subscribeNext:^(SpreePost* post) {
        // do something
    }];

}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    [super dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
}

-(UIView *)titleLabel{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"CREATE NEW POST";
    titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor spreeOffBlack];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    return titleLabel;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.active = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.viewModel.active = NO;
}


-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kAuthorizeLocationServicesAlert || alertView.tag == kMarketUnavailableAlert){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
