//
//  PostingLocationEntryViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/22/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostingLocationEntryViewController.h"

@interface PostingLocationEntryViewController () <UISearchControllerDelegate, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource> {

}

@property (nonatomic, strong) UITableViewController *resultsTableViewController;
@property (nonatomic, strong) NSArray *searchResults;
@property CLLocationManager *locationManager;


// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation PostingLocationEntryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationMapView.delegate = self;
    self.locationMapView.showsUserLocation = YES;
    
    [self setupSearchController];
    [self setupLocationManager];
    
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:[self userSelectedLocation]];
    
    self.definesPresentationContext = YES;
}


-(void)setupSearchController{
    // The TableViewController used to display the results of a search
    self.resultsTableViewController =  [[UITableViewController alloc] init];
    self.resultsTableViewController.automaticallyAdjustsScrollViewInsets = NO; // Remove table view insets
    self.resultsTableViewController.tableView.dataSource = self;
    self.resultsTableViewController.tableView.delegate = self;
    // Initialize our UISearchController
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableViewController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.resultsTableViewController.view.backgroundColor = [UIColor spreeOffWhite];
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
}

-(void) setupSearchBar {
    self.searchController.searchBar.frame = CGRectMake(0, 0, self.topView.frame.size.width, self.topView.frame.size.height);
    self.searchController.searchBar.showsCancelButton = NO;
    self.searchController.searchBar.placeholder = self.prompt;
    self.searchController.searchBar.backgroundColor = [UIColor spreeOffWhite];
    self.searchController.searchBar.barTintColor = [UIColor spreeOffWhite];
    self.searchController.searchBar.tintColor = [UIColor spreeDarkBlue];
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [self.topView addSubview: self.searchController.searchBar];

    // Add SearchController's search bar to our view and bring it to front
    [self.view bringSubviewToFront:self.containingTopView];
}


-(void)viewDidLayoutSubviews{
    [self setupSearchBar];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self.locationMapView removeAnnotations:self.locationMapView.annotations];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:[self userSelectedLocation]];
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:[self userSelectedLocation]];
    return YES;
}
#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
    [searchController.searchBar resignFirstResponder];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}


-(void)willPresentSearchController:(UISearchController *)aSearchController {
    
    aSearchController.searchBar.bounds = CGRectInset(aSearchController.searchBar.frame, 0.0f, 0.0f);
//
    // Set the position of the result's table view below the status bar and search bar
    // Use of instance variable to do it only once, otherwise it goes down at every search request
    if (CGRectIsEmpty(_searchTableViewRect)) {
    
        CGRect tableViewFrame = ((UITableViewController *)aSearchController.searchResultsController).tableView
        .frame;
        tableViewFrame.origin.y = self.containingTopView.frame.origin.y + self.containingTopView.frame.size.height;
        tableViewFrame.size.height =  self.locationMapView.frame.size.height;
        
        _searchTableViewRect = tableViewFrame;
    }
    
    [((UITableViewController *)aSearchController.searchResultsController).tableView setFrame:_searchTableViewRect];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self searchQuery: searchController.searchBar.text];
}

#pragma mark - Local Search

- (void)searchQuery:(NSString *)query {
    // Cancel any previous searches.
    
    [[PFUser currentUser][@"campus"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
        [self.localSearch cancel];
        
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        if ([(PFGeoPoint *)object[@"location"] longitude]){
            CLLocationCoordinate2D campusLocation = CLLocationCoordinate2DMake([(PFGeoPoint *)object[@"location"] latitude], [(PFGeoPoint *)object[@"location"] longitude]);
            request.region = MKCoordinateRegionMakeWithDistance(campusLocation, 5000, 5000);
            request.naturalLanguageQuery = query;
            
        } else {
            request.naturalLanguageQuery = query;
            request.region = self.locationMapView.region;
        }
        
        self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
        [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            NSLog(@"%@", response.mapItems);
            // hand over the filtered results to our search results table
            self.results = response;
            UITableViewController *tableController = (UITableViewController *)self.searchController.searchResultsController;
            [tableController.tableView reloadData];
        }];
        
    }];

    
    
}

#pragma mark - MapView

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
//    if (self.searchController.active)
//        [self.searchController setActive:NO];
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:[self userSelectedLocation]];
}

#pragma mark - Location

- (void) setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Will call locationManager:didChangeAuthorizationStatus: delegate method
    [CLLocationManager authorizationStatus];
}


- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSString *message = @"You must enable Location Services for this app in order to use it.";
    NSString *button = @"Ok";
    NSString *title;
    
    if (status == kCLAuthorizationStatusDenied) {
        title = @"Location Services Disabled";
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:button, nil] show];
    } else if(status == kCLAuthorizationStatusRestricted) {
        title = @"Location Services Restricted";
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:button, nil] show];
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // Note: kCLAuthorizationStatusAuthorizedWhenInUse depends on the request...Authorization
        // (Always or WhenInUse)
        if ([self enableLocationServices]) {
            NSLog(@"Location Services enabled.");
        } else {
            NSLog(@"Couldn't enable Location Services. Please enable them in Settings > Privacy > Location Services.");
        }
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"Error : Authorization status not determined.");
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (BOOL) enableLocationServices {
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.distanceFilter = 10;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
        [self.locationMapView setRegion:MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, 1000, 1000)];
        [self.locationMapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];

        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = self.results.mapItems[indexPath.row];
    
    cell.textLabel.text = item.placemark.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results.mapItems count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.locationMapView removeAnnotations:self.locationMapView.annotations];
    
    // Hide search controller
    [self.searchController setActive:NO];
    
    MKMapItem *item = self.results.mapItems[indexPath.row];
    
    NSLog(@"Selected \"%@\"", item.placemark.name);
    
    self.selectedGeoPoint = [PFGeoPoint geoPointWithLocation:item.placemark.location];
    
    [self.locationMapView addAnnotation:item.placemark];
    [self.locationMapView selectAnnotation:item.placemark animated:YES];
    
    [self.locationMapView setCenterCoordinate:item.placemark.location.coordinate animated:NO];
    
    [self.locationMapView setUserTrackingMode:MKUserTrackingModeNone];
    
    [self.searchController.searchBar setText:item.placemark.name];
    
}

#pragma mark - Workflow

-(void)nextBarButtonItemTouched:(id)sender{
    self.postingWorkflow.post[self.fieldTitle] = self.selectedGeoPoint;
    if (self.presentedWithinWorkflow){
//        [self.postingWorkflow.post[@"completedFields"] addObject:self.fieldDictionary];
//        self.postingWorkflow.step++;
//        UIViewController *nextViewController =[self.postingWorkflow nextViewController];
//        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

#pragma mark - Data Validation


-(BOOL)userSelectedLocation{
    NSLog(@"%lu", (unsigned long)[self.locationMapView annotations].count);
    if ([self.locationMapView annotations].count > 1){
        return YES;
    } else {
        return NO;
    }
}

@end
