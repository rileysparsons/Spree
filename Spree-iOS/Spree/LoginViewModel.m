//
//  EnterEmailViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "LoginViewModel.h"
#import "SpreeViewModelServicesImpl.h"
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "MainPostTableViewController.h"
#import "AppDelegate.h"

@interface LoginViewModel ()

@property (nonatomic, strong) id<SpreeViewModelServices> services;

@end

@implementation LoginViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

-(void)initialize{
    @weakify(self)
    self.loginWithFacebook = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [self loginWithFacebookSignal];
    }];
}

-(RACSignal *)loginWithFacebookSignal {
    @weakify(self)
    return [[[self.services getParseConnection] loginWithFacebook] doNext:^(id x) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id,name"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            [PFUser currentUser][@"fbId"] = result[@"id"];
            [PFUser currentUser][@"displayName"] = result[@"name"];
            
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                @strongify(self)
                [self closeOnboarding];
            }];
        }];
    }];
}

-(void)closeOnboarding{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabBarController = [stb instantiateInitialViewController];
    UINavigationController *navController = [tabBarController.viewControllers objectAtIndex:0];
    
    MainPostTableViewController *mainPostTableViewController = [navController.viewControllers objectAtIndex:0];
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    mainPostTableViewController.viewModel = [[PostTableViewModel alloc] initWithServices:viewModelServices];

    
    [UIView transitionWithView:appDelegate.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ appDelegate.window.rootViewController = tabBarController; }
                    completion:nil];
}


@end
