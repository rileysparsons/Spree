//
//  AppDelegate.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "AppDelegate.h"
#import "BrowseViewController.h"
#import "SpreeViewModelServicesImpl.h"
#import "MainPostTableViewController.h"
#import "LoginViewController.h"
#import "RTWalkthroughViewController.h"
#import "RTWalkthroughPageViewController.h"
#import "BaseOnboardingViewController.h"
#import "SpreePost.h"
#import "ChatView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import "Branch.h"
#import "PostDetailTableViewController.h"
#import "SpreeConfigManager.h"
#import <Accelerate/Accelerate.h>

@interface AppDelegate () <RTWalkthroughViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Register Parse Subclass
    self.analyticsClient = [AWSMobileAnalytics mobileAnalyticsForAppId: @"38a4f0080b5b408a901f52c35189a7c1" identityPoolId: @"us-east-1:e6a26501-5646-44b7-85ab-79eb226ceb33"];

    
    [SpreePost registerSubclass];
    [ParseCrashReporting enable];
#warning These are test keys, switch before merging.
    [Parse setApplicationId:@"QJpsxjWbeXTqp79rPMUA48xSOUxfZe1Y72uXaT7E"
                  clientKey:@"3TlfMPxRPAmJv6apfea4tAZQqt2w6G3vXWPswEpG"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    [[UINavigationBar appearance] setTintColor:[UIColor spreeOffBlack]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor spreeOffWhite]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor spreeDarkBlue], NSFontAttributeName: [UIFont fontWithName:@"Lato" size:0.0],
        }];
    [[UITabBar appearance] setTintColor:[UIColor spreeDarkBlue]];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTranslucent:NO];
    [[UISegmentedControl appearance] setTintColor:[UIColor spreeDarkBlue]];

    
    
    
    
    
    [[SpreeConfigManager sharedManager] fetchConfigIfNeeded];
    
    //Branch stuff
//    [Branch setDebug]; // For TESTING, NOT DEPLOYMENT
//    #warning REMOVE BEFORE DEPLOYING TO APP STORE
    Branch *branch = [Branch getInstance];
    if ([PFUser currentUser]){
        [branch setIdentity:[PFUser currentUser].objectId];
    }
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        // route the user based on what's in params
        // params are the deep linked params associated with the link that the user clicked before showing up.
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        NSLog(@"deep link data: %@", [params description]);
        if ([params objectForKey:@"object id"] != nil && [PFUser currentUser]){

            UITabBarController *tabBarController =  (UITabBarController *)self.window.rootViewController;
            
            UINavigationController *homeNavigationController = [[tabBarController viewControllers] objectAtIndex:SpreeCampusTabBarItemIndex];
            
            [tabBarController setSelectedViewController:homeNavigationController];
            
            PostDetailTableViewController *postDetailTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostDetail"];
            
            [postDetailTableViewController initializeWithObjectId:params[@"object id"]];
            
            [homeNavigationController pushViewController:postDetailTableViewController animated:YES ];
            
        }
    }];
    
    if (![PFUser currentUser]) {
        [self showOnboardingFlow];
    } else {
        UITabBarController *tabBarController =  (UITabBarController *)self.window.rootViewController;
        
        UINavigationController *homeNavigationController = [[tabBarController viewControllers] objectAtIndex:SpreeCampusTabBarItemIndex];
        
        MainPostTableViewController *mainPostTableViewController = [homeNavigationController.viewControllers objectAtIndex:0];
        
        // Attaching View Model Services to View Model (gives us access to Parse, our model)
        SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
        
        PostTableViewModel *viewModel = [[PostTableViewModel alloc] initWithServices:viewModelServices Params:@{@"expired": @NO, @"sold": @NO}];
        mainPostTableViewController.viewModel = viewModel;
        
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
    [[Branch getInstance] handleDeepLink:url];
    
    // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
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

- (void)logOut {
    // clear cache
//    [[PAPCache sharedCache] clear];
    
    // clear NSUserDefaults
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
//    [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
//    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    
    [PFUser logOutInBackgroundWithBlock:^(NSError *error){
        [FBSDKAccessToken setCurrentAccessToken:nil];
        //            [FBSDKProfile setCurrentProfile:nil];
        UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
        UINavigationController *base = [stb instantiateViewControllerWithIdentifier:@"base"];
        [UIView transitionWithView:self.window
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{ self.window.rootViewController = base; }
                        completion:nil];
        
        UITabBarController *tabBarController =  (UITabBarController *)self.window.rootViewController;
        
        UINavigationController *homeNavigationController = [[tabBarController viewControllers] objectAtIndex:SpreeCampusTabBarItemIndex];
        
        homeNavigationController = nil;
        
    }];
    
    
    // clear out cached data, view controllers, etc
    
//    [self presentLoginViewController];
//    
//    self.homeViewController = nil;
//    self.activityViewController = nil;
}


@end
