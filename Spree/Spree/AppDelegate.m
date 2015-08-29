//
//  AppDelegate.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "AppDelegate.h"
#import "BrowseViewController.h"
#import "LoginViewController.h"
#import "PostDetailViewController.h"
#import "FinalOnboardingViewController.h"
#import "RTWalkthroughViewController.h"
#import "RTWalkthroughPageViewController.h"
#import "BaseOnboardingViewController.h"
#import "LoginViewController.h"
#import "SpreePost.h"
#import "ChatView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import "Branch.h"
#import "PostDetailTableViewController.h"
#import <Accelerate/Accelerate.h>

@interface AppDelegate () <RTWalkthroughViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Register Parse Subclass
    
    //Branch.io stuff
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        
        // params are the deep linked params associated with the link that the user clicked before showing up.
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"main" bundle:[NSBundle mainBundle]];
        if ([params objectForKey:@"object id"]){
            PostDetailTableViewController *postDetailTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
            [postDetailTableViewController initializeWithObjectId:params[@"object id"]];
            [self.window.rootViewController presentViewController:postDetailTableViewController animated:YES completion:nil];
            //I assume this is where you should put the initialization
            
        }
        
        
        
    }];
    
    
    
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
    
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    [[UINavigationBar appearance] setTintColor:[UIColor spreeOffBlack]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor spreeOffWhite]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor spreeDarkBlue], NSFontAttributeName: [UIFont fontWithName:@"Lato" size:0.0],
        }];
    [[UITabBar appearance] setTintColor:[UIColor spreeDarkBlue]];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTranslucent:NO];
    [[UISegmentedControl appearance] setTintColor:[UIColor spreeDarkBlue]];
    
    if (![PFUser currentUser]) {
        [self showOnboardingFlow];
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

- (void)showOnboardingFlow {
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
    UINavigationController *base = [stb instantiateViewControllerWithIdentifier:@"base"];
    
    self.window.rootViewController = base;
    [self.window makeKeyAndVisible];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [FBSDKAppEvents activateApp];
    if (currentInstallation.badge != 0) {
        NSLog(@"current installation: %ld", (long)currentInstallation.badge);
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    //Branch.io stuff
    [[Branch getInstance] handleDeepLink:url];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
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
    NSLog(@"Did receive");
    if ([PFUser currentUser]){
        if (application.applicationState != UIApplicationStateActive && [[userInfo objectForKey:@"type"] isEqualToString:@"message"]) {
            UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
            [tabBarController setSelectedIndex:2];
            UINavigationController *navigationController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:2];
            PFObject *postObject = [PFObject objectWithoutDataWithClassName:@"Post" objectId:[userInfo objectForKey:@"postId"]];
            ChatView *message = [[ChatView alloc] initWith:[userInfo objectForKey:@"groupId"] post:postObject title:[userInfo objectForKey:@"title"]];
            [navigationController pushViewController:message animated:YES];
        }
        if (application.applicationState == UIApplicationStateActive && [[userInfo objectForKey:@"type"] isEqualToString:@"message"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMessages" object:nil];
                PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
                [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
                [query includeKey:PF_RECENT_LASTUSER];
                [query orderByDescending:PF_RECENT_UPDATEDACTION];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                 {
                     if (objects)
                     {
                         int total = 0;
                         for (PFObject *recent in objects)
                         {
                             total += [recent[PF_RECENT_COUNTER] intValue];
                         }
                         UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
                         UITabBarItem *item = tabBarController.tabBar.items[2];
                         item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
                     }
                 }];
        }
    }
}

-(void)checkForUnreadMessages{
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
    [query includeKey:PF_RECENT_LASTUSER];
    [query orderByDescending:PF_RECENT_UPDATEDACTION];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (objects)
         {
             int total = 0;
             for (PFObject *recent in objects)
             {
                 total += [recent[PF_RECENT_COUNTER] intValue];
             }
             UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
             UITabBarItem *item = tabBarController.tabBar.items[2];
             item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
         }
     }];
}

@end
