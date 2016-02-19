//
//  AppDelegate.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "Branch.h"
#import <AWSMobileAnalytics/AWSMobileAnalytics.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property CLLocationManager *locationManager;
@property UINavigationController *navigationController;
@property NSInteger expiredPostCount;
@property AWSMobileAnalytics *analyticsClient;

-(void)logOut;

@end

