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
    
    RAC(self, authStatus) = [RACObserve(self.service, authorizationStatus) ignore:nil];
    
    RAC(self, currentLocation) = [self locationSignal];
    NSLog(@"%@", self.service.authorizationStatus);
    [[self.service authorizationStatus] map:^id(id value) {
        CLAuthorizationStatus status = [value intValue];
        if (status == kCLAuthorizationStatusDenied){
            self.locationServicesAllowed = NO;
        } else {
            self.locationServicesAllowed = YES;
        }
        return nil;
    }];
      
    self.requestLocationServices = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [self requestLocationAuthSignal];
    }];
    
    [[self requestLocationAuthSignal] then:^RACSignal *{
        [self locationSignal];
        return nil;
    }];
    
    RAC(self, locationServicesAllowed) = [[_service authorizationStatus] map:^id(id value) {
        CLAuthorizationStatus status = [value intValue];
        NSLog(@"%d", status);
        if (status == kCLAuthorizationStatusDenied){
            return @NO;
        } else {
            return @YES;
        }
    }];
    
    // subscribe to authorization status
    [[_service authorizationStatus]
     subscribeNext:^(NSNumber *statusNumber) {
         
         CLAuthorizationStatus status = [statusNumber intValue];
         switch (status) {
             case kCLAuthorizationStatusNotDetermined:
                 NSLog(@"[INFO] Status changed: kCLAuthorizationStatusNotDetermined");
                 break;
             case kCLAuthorizationStatusRestricted:
                 NSLog(@"[INFO] Status changed: kCLAuthorizationStatusRestricted");
                 break;
             case kCLAuthorizationStatusDenied:
                 NSLog(@"[INFO] Status changed: kCLAuthorizationStatusDenied");
                 break;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
             case kCLAuthorizationStatusAuthorizedAlways:
                 NSLog(@"[INFO] Status changed: kCLAuthorizationStatusAuthorizedAlways");
                 break;
             case kCLAuthorizationStatusAuthorizedWhenInUse:
                 NSLog(@"[INFO] Status changed: kCLAuthorizationStatusAuthorizedWhenInUse");
                 break;
#else
             case kCLAuthorizationStatusAuthorized:
                 NSLog(@"[INFO] Status changed: kCLAuthorizationStatusAuthorized");
                 break;
#endif
             default:
                 break;
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
