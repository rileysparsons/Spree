//
//  ConfirmLocationViewController.m
//  
//
//  Created by Riley Steele Parsons on 12/26/15.
//
//

#import "ConfirmLocationViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ConfirmLocationViewController () <MKMapViewDelegate>

@property CLLocation *postLocation;

@end

@implementation ConfirmLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView.delegate = self;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor spreeOffWhite];
    self.navigationController.navigationBar.backgroundColor = [UIColor spreeOffWhite];
    
    self.view.backgroundColor = [UIColor spreeOffWhite];
    
    self.cancelButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return [RACSignal return:nil];
    }];
    
    [self bindPostingWorkflow];
    @weakify(self)
    self.acceptButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self)
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            [self.viewModel.confirmLocationCommand execute:nil];
            return nil;
        }];
    }];
    
    
    CLLocationDistance marketRadius = 8500;
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.postLocation.coordinate radius:marketRadius];
    [self.mapView addOverlay:circle];
    
}

-(void)bindPostingWorkflow{
    
    PFGeoPoint *postLocation = self.viewModel.post[@"location"];
    self.postLocation = [[CLLocation alloc] initWithLatitude:postLocation.latitude longitude:postLocation.longitude];

    
    RAC(self.addressLabel, text) = [[[[[RACObserve(self, postLocation) doNext:^(id x) {
        [self centerMapViewAtLocation:x];
    }] flattenMap:^RACStream *(CLLocation *location) {
        return [self signalForReverseGeocodeWithLocation:location];
    }] map:^id(NSArray *placemarks) {
        return placemarks.firstObject;
    }] map:^id(CLPlacemark *placemark) {
        return placemark.addressDictionary[@"FormattedAddressLines"];
    }] map:^id(NSArray *addressLines) {
        return addressLines.firstObject;
    }];
    
}

-(void)centerMapViewAtLocation:(CLLocation *)location{
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, 8500*2+1000, 8500*2+1000) animated:YES];
}
                                      
- (RACSignal *)signalForReverseGeocodeWithLocation:(CLLocation *)location {

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error){
                NSLog(@"Geocode failed with error: %@", error);
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:placemarks];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{

    MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    renderer.fillColor = [UIColor spreeDarkBlue];
    renderer.alpha = 0.2f;
    return renderer;
    
}

@end
