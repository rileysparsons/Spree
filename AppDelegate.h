//
//  AppDelegate.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SecondViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, SecondViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property CLLocationManager *locationManager;
@property UINavigationController *navigationController;
@property NSInteger expiredPostCount;


@end

