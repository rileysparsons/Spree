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
#import "SecondViewController.h"
#import "UIColor+SpreeColor.h"
#import "PostDetailViewController.h"
#import "UserPostTableViewController.h"
#import "SpreePost.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Accelerate/Accelerate.h>

@interface AppDelegate () <LoginViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Register Parse Subclass
    [SpreePost registerSubclass];
    
    [Parse setApplicationId:@"F2jyNwFtpy0O9ufRLxBnMQWRtGQju6kV0JEbUZlf"
                  clientKey:@"T7noUkx7fvw5KwLxWi0Y6brf3c3LaqWb6ODoB6IZ"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
    self.locationManager = _locationManager;
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor spreeBabyBlue]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Neue" size:0.0],
        }];
    [[UITabBar appearance] setTintColor:[UIColor spreeBabyBlue]];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTranslucent:NO];
    [[UISegmentedControl appearance] setTintColor:[UIColor spreeBabyBlue]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    [PFFacebookUtils initializeFacebook];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([PFUser currentUser]){
        [self presentHomeViewController:NO];
        
    } else {
        [self presentLoginViewController];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SecondViewController *secondViewController = [storyboard instantiateViewControllerWithIdentifier:@"SecondViewController"];
    secondViewController.delegate = self;
    
//    NSLog(@"%@", [[(UITabBarController *)self.window.rootViewController ] viewControllers]);
    // Push handling
   
    // Extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationPayload){
        
    
        /*
        // Create a pointer to the Photo object
        //     Create empty photo object
        NSString *postId = [notificationPayload objectForKey:@"post"];
        PFObject *targetPost = [PFObject objectWithoutDataWithClassName:@"Post"
                                                               objectId:postId];
        
        // Fetch photo object
        [targetPost fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            // Show photo view controller
            if (!error && [PFUser currentUser]) {
                         [(UITabBarController *)self.window.rootViewController setSelectedIndex:1];
                NSLog(@"%@", [[(UITabBarController *)self.window.rootViewController viewControllers] objectAtIndex:0]);
//                    UINavigationController *navController = (UINavigationController *)[[(UITabBarController *)self.window.rootViewController viewControllers] objectAtIndex:0];
//                UserPostTableViewController *userPosts = [storyboard instantiateViewControllerWithIdentifier:@"UserPost"];
//                [navController pushViewController:userPosts animated:NO];
         
            }
        }];
         */
    }

    if ([PFUser currentUser]){
        PFQuery *expiredPostNumberQuery = [PFQuery queryWithClassName:@"Post"];
        [expiredPostNumberQuery whereKey:@"user" equalTo:[PFUser currentUser]];
        [expiredPostNumberQuery  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error){
                NSMutableArray *expiredPosts = [[NSMutableArray alloc] init];
                NSMutableArray *activePosts = [[NSMutableArray alloc] init];
                
                for (SpreePost *post in objects){
                    if (post.expired == YES){
                        [expiredPosts addObject:post];
                    } else {
                        [activePosts  addObject:post];
                    }
                }
                self.expiredPostCount = expiredPosts.count;
                UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
                UINavigationController *navigationController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:2];
                if (self.expiredPostCount != 0){
                    [navigationController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%li", self.expiredPostCount]];
                } else {
                    [navigationController.tabBarItem setBadgeValue:nil];
                }
            }
        }];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
     
    if (currentInstallation.badge != 0) {
        NSLog(@"current installation: %ld", (long)currentInstallation.badge);
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
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
    if ([PFUser currentUser]){
        PFQuery *expiredPostNumberQuery = [PFQuery queryWithClassName:@"Post"];
        [expiredPostNumberQuery whereKey:@"user" equalTo:[PFUser currentUser]];
        [expiredPostNumberQuery  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error){
                NSMutableArray *expiredPosts = [[NSMutableArray alloc] init];
                NSMutableArray *activePosts = [[NSMutableArray alloc] init];
                
                for (SpreePost *post in objects){
                    if (post.expired == YES){
                        [expiredPosts addObject:post];
                    } else {
                        [activePosts  addObject:post];
                    }
                }
                self.expiredPostCount = expiredPosts.count;
                UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
                UINavigationController *navigationController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:2];
                [navigationController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%li", self.expiredPostCount]];
            }
        }];
    }
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


    - (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo{
//        [PFPush handlePush:userInfo];


        NSString *postId = [userInfo objectForKey:@"post"];
        PFObject *targetPost = [PFObject objectWithoutDataWithClassName:@"Post"
                                                               objectId:postId];
        
        NSLog(@"%@", postId);
        [targetPost fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//             Show photo view controller
            NSLog(@"fetch is calling");
            
            if (error) {
                
//                handler(UIBackgroundFetchResultFailed);
            } else if ([PFUser currentUser]) {
                UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
                [tabBarController setSelectedIndex:1];
                UINavigationController *navigationController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:2];
                PostDetailViewController *notificationController = (PostDetailViewController*) [navigationController.storyboard instantiateViewControllerWithIdentifier:@"PostDetail"];
                [notificationController setDetailPost:(SpreePost *)object];
                [navigationController pushViewController:notificationController animated:YES];
 //THIS WORKS!
//                handler(UIBackgroundFetchResultNewData);
            } else {
//                handler(UIBackgroundFetchResultNoData);
            }
        }];
 
}


#pragma mark LoginViewController
- (void)presentLoginViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    loginViewController.delegate = self;
    self.window.rootViewController = loginViewController;
    [self.window makeKeyAndVisible];
}

#pragma mark HomeViewController

- (void)presentHomeViewController:(BOOL)animated {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [self.window makeKeyAndVisible];
    NSLog(@"present called!");
}

#pragma mark LoginViewController delegate methods
-(void)loginViewControllerDidLogin:(LoginViewController *)controller{
    // Push notification setup
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [self presentHomeViewController:NO];
}

-(void)secondViewControllerDidLogout:(SecondViewController *)controller{
    NSLog(@"called in app delegate");
    [self presentLoginViewController];
}
@end
