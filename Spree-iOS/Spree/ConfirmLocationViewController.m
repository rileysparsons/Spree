//
//  ConfirmLocationViewController.m
//  
//
//  Created by Riley Steele Parsons on 12/26/15.
//
//

#import "ConfirmLocationViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ConfirmLocationViewController ()

@property CLLocation *postLocation;

@end

@implementation ConfirmLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self bindPostingWorkflow];
    
    self.acceptButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            return nil;
        }];
    }];
    
    
}

-(void)bindPostingWorkflow{
    
    PFGeoPoint *postLocation = self.postingWorkflow.post[@"location"];
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
    [self.mapView setCenterCoordinate:location.coordinate animated:YES];
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

@end
