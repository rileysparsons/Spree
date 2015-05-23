//
//  AppDelegate.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "PostDetailViewController.h"
#import "SpreePost.h"
#import "ChatView.h"
#import <ParseCrashReporting/ParseCrashReporting.h>



#import <Accelerate/Accelerate.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Register Parse Subclass
    
    [SpreePost registerSubclass];
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"F2jyNwFtpy0O9ufRLxBnMQWRtGQju6kV0JEbUZlf"
                  clientKey:@"T7noUkx7fvw5KwLxWi0Y6brf3c3LaqWb6ODoB6IZ"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

//    _locationManager = [[CLLocationManager alloc] init];
//    [_locationManager setDelegate:self];
//    [_locationManager requestWhenInUseAuthorization];
//    [_locationManager startUpdatingLocation];
//    self.locationManager = _locationManager;

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor spreeBabyBlue]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Neue" size:0.0],
        }];
    [[UITabBar appearance] setTintColor:[UIColor spreeBabyBlue]];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTranslucent:NO];
    [[UISegmentedControl appearance] setTintColor:[UIColor spreeBabyBlue]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    if (![PFUser currentUser]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"login"];
        self.window.rootViewController = loginViewController;
        [self.window makeKeyAndVisible];
    }
    
    if ([PFUser currentUser]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
     
    if (currentInstallation.badge != 0) {
        NSLog(@"current installation: %ld", (long)currentInstallation.badge);
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }

}


- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Did Register");
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    currentInstallation[@"user"] = [PFUser currentUser];
    [currentInstallation saveInBackground];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{

    if (application.applicationState != UIApplicationStateActive && [[userInfo objectForKey:@"type"] isEqualToString:@"message"]) {
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        [tabBarController setSelectedIndex:2];
        UINavigationController *navigationController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:2];
        PFObject *postObject = [PFObject objectWithoutDataWithClassName:@"Post" objectId:[userInfo objectForKey:@"postId"]];
        ChatView *message = [[ChatView alloc] initWith:[userInfo objectForKey:@"groupId"] post:postObject title:[userInfo objectForKey:@"title"]];
        [navigationController pushViewController:message animated:YES];
    }

//        NSString *postId = [userInfo objectForKey:@"post"];
//        PFObject *targetPost = [PFObject objectWithoutDataWithClassName:@"Post"
//                                                               objectId:postId];
//        
//        NSLog(@"%@", postId);
//        [targetPost fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
////             Show photo view controller
//            NSLog(@"fetch is calling");
//            
//            if (error) {
//                
////                handler(UIBackgroundFetchResultFailed);
//            } else if ([PFUser currentUser]) {
//                UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
//                [tabBarController setSelectedIndex:1];
//                UINavigationController *navigationController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:2];
//                PostDetailViewController *notificationController = (PostDetailViewController*) [navigationController.storyboard instantiateViewControllerWithIdentifier:@"PostDetail"];
//                [notificationController setDetailPost:(SpreePost *)object];
//                [navigationController pushViewController:notificationController animated:YES];
// //THIS WORKS!
////                handler(UIBackgroundFetchResultNewData);
//            } else {
////                handler(UIBackgroundFetchResultNoData);
//            }
//        }];

}

@end
