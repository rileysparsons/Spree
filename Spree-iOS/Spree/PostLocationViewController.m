//
//  PostLocationViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/15/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "PostLocationViewController.h"
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>

@interface PostLocationViewController ()

@property NSArray *returnedMapItems;
@property NSDictionary *selectedLocation;


@end

@implementation PostLocationViewController

@synthesize postLocationDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationMapView.delegate = self;
    self.locationMapView.showsUserLocation = YES;
    
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocation *currentLocation=appDelegate.locationManager.location;
    MKCoordinateRegion region =  MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1000, 1000);
    [_locationMapView setShowsUserLocation:YES];
    [_locationMapView setRegion:region];
    

}

# pragma mark UISearchDisplayController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _returnedMapItems.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0){
        cell.textLabel.text = @"Current Location";
        cell.textLabel.textColor = [UIColor blueColor];
        
    } else {
    

    
    // Configure the cell with the textContent of the Post as the cell's text label
    cell.textLabel.text = [(MKMapItem*)[_returnedMapItems objectAtIndex:indexPath.row-1] name];
        cell.detailTextLabel.text = [[[(MKMapItem*)[_returnedMapItems objectAtIndex:indexPath.row-1] placemark] addressDictionary] objectForKey:(NSString *)kABPersonAddressStreetKey];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        [_locationMapView selectAnnotation:_locationMapView.userLocation animated:YES];
        [self.searchDisplayController setActive:NO animated:YES];
        _selectedLocation = [NSDictionary dictionaryWithObjectsAndKeys:@"Current Location", @"name", _locationMapView.userLocation.location, @"coordinate", nil];
        _locationSearchBar.placeholder = @"Current Location";
        MKPlacemark *currentLocation = [[MKPlacemark alloc] initWithCoordinate:_locationMapView.userLocation.location.coordinate addressDictionary:nil];
        [_locationMapView addAnnotation:currentLocation];
    } else {
        MKMapItem *mapItem = (MKMapItem *)[_returnedMapItems objectAtIndex:0];
        
        MKCoordinateRegion region;
        
        MKCoordinateSpan span;
        double radius = [(CLCircularRegion *)mapItem.placemark.region radius] / 1000; // convert to km
        
        NSLog(@"[searchBarSearchButtonClicked] Radius is %f", radius);
        span.latitudeDelta = radius / 112.0;
        
        region = MKCoordinateRegionMake(mapItem.placemark.location.coordinate, span);
        
        _selectedLocation = [[NSDictionary alloc ] initWithObjectsAndKeys:mapItem.placemark.name, @"name", mapItem.placemark.addressDictionary, @"address", mapItem.placemark.location, @"coordinate", nil];
        [_locationMapView addAnnotation:mapItem.placemark];
        [_locationMapView setRegion:region animated:NO];
        [self.searchDisplayController setActive:NO animated:YES];
    }
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"String: %@", searchString);
    
    MKLocalSearchRequest *localSearchRequest = [[MKLocalSearchRequest alloc] init];
    localSearchRequest.naturalLanguageQuery = searchString;
    localSearchRequest.region = MKCoordinateRegionMakeWithDistance(_locationMapView.userLocation.coordinate, 1000, 1000);
    
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:localSearchRequest];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        _returnedMapItems = response.mapItems;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
    return NO;
}
- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.postLocationDelegate postLocationViewController:self didFinishSelecting:_selectedLocation];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
