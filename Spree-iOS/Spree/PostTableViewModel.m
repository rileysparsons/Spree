//
//  PostTableViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/17/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostTableViewModel.h"
#import <MMPReactiveCoreLocation/MMPReactiveCoreLocation.h>

@interface PostTableViewModel ()

@property (nonatomic, strong) id<SpreeViewModelServices> services;
@property CLLocation *currentLocation;
@property (nonatomic, strong) MMPReactiveCoreLocation *service;
@property CLAuthorizationStatus authStatus;

@end

@implementation PostTableViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

-(void)initialize{
    
    self.posts = [[NSArray alloc] init];
    
    [self initializeLocationService];
    
    @weakify(self);

    self.refreshPosts = [[RACCommand alloc] initWithEnabled:nil signalBlock:^RACSignal *(id input) {
        NSLog(@"HERE");
        @strongify(self);
        return [self refreshPostsSignalForCurrentLocation];
    }];
    
    RAC(self, posts) =
    [[[self.refreshPosts executionSignals]
      switchToLatest]
     ignore:nil];
    
    [[[self didBecomeActiveSignal]
    flattenMap:^id(id value) {
        return [[RACObserve(self, currentLocation) ignore:NULL] take:1];
    }] subscribeNext:^(id x) {
        NSLog(@"returned from initial block: %@", x);
        [self.refreshPosts execute:nil];
    }];

}

- (void)initializeLocationService{
    
    self.service = [MMPReactiveCoreLocation service];
    
    RAC(self, currentLocation) = [self locationSignal];
    
    RAC(self, shouldHidePosts) = [[self.service authorizationStatus] map:^id(NSNumber* value) {
        if ([value integerValue] == 2){
            return @YES;
        } else {
            return @NO;
        }
    }];
}

-(RACSignal *)refreshPostsSignalForCurrentLocation{
    NSLog(@"current loc: %@", self.currentLocation);
    return [[[self.services getParseConnection] refreshPostsForCurrentLocation:self.currentLocation] timeout:10 onScheduler:RACScheduler.scheduler];
}


- (RACSignal *)requestLocationAuthSignal {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [[[self.service authorizeWhenInUse] authorize] subscribeNext:^(id x) {
            [subscriber sendNext:x];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (RACSignal *)locationSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[_service locations] subscribeNext:^(id x) {
            [subscriber sendNext:x];
        }];
        return nil;
    }];
}

@end
