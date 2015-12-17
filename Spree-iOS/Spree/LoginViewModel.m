//
//  EnterEmailViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "LoginViewModel.h"
#import "AppDelegate.h"
#import "PostTableViewController.h"

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
    self.loginWithFacebook = [[RACCommand alloc] initWithEnabled:nil signalBlock:^RACSignal *(id input) {
        return [self loginWithFacebookSignal];
    }];
}

-(RACSignal *)loginWithFacebookSignal {
    return [[[self.services getParseConnection] loginWithFacebook] doNext:^(id x) {
        [self closeOnboarding];
    }];
}

-(void)closeOnboarding{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    PostTableViewController *postTableViewController = [stb instantiateInitialViewController];
    [UIView transitionWithView:appDelegate.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ appDelegate.window.rootViewController = postTableViewController; }
                    completion:nil];
}


@end
