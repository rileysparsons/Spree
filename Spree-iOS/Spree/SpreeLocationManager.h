//
//  SpreeLocationManager.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/17/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
@import CoreLocation;

@interface SpreeLocationManager : NSObject

+ (instancetype) sharedManager;

@property (nonatomic,readonly) CLLocationManager* locationManager;

- (void) requestWhenInUseAuthorization ;
- (void) requestAlwaysAuthorization;

- (RACSignal *)rac_signalForAllLocationUpdates;
- (RACSignal*) rac_signalForMostAccurateLocationUpdates;
- (RACSignal*) rac_signalForCurrentLocation;

@end
