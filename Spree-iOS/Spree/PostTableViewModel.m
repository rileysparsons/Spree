//
//  PostTableViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/17/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostTableViewModel.h"
#import "SpreeLocationManager.h"

@interface PostTableViewModel ()

@property (nonatomic, strong) id<SpreeViewModelServices> services;
@property CLLocation *currentLocation;

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
    
    @weakify(self);
    RAC(self, currentLocation) = [[SpreeLocationManager sharedManager] rac_signalForCurrentLocation];

    RAC(self, locationServicesAuthorized) = [self authorizationStatusSignal];
    
    [RACObserve(self, locationServicesAuthorized) filter:^BOOL(id value) {
        if ([value boolValue] == YES){
            @strongify(self);
            [self.refreshPosts execute:nil];
        };
        return nil;
    }];
    
    NSLog(@"location %@", [NSNumber numberWithBool:self.locationServicesAuthorized]);

    self.refreshPosts = [[RACCommand alloc] initWithEnabled:nil signalBlock:^RACSignal *(id input) {
        NSLog(@"HERE");
        @strongify(self);
        
        return [[[self.services getParseConnection] refreshPostsForCurrentLocation:self.currentLocation]
                timeout:10 onScheduler:RACScheduler.scheduler];
    
    }];
    
    self.requestLocationServices = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        RACSignal *requestAuthSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [[SpreeLocationManager sharedManager] requestWhenInUseAuthorization];
            return nil;
        }];
        return requestAuthSignal;
    }];
    
    [[[self.requestLocationServices executionSignals] switchToLatest] subscribeNext:^(id x) {
        [self.refreshPosts execute:nil];
    }];
    
    RAC(self, posts) =
    [[[self.refreshPosts executionSignals]
      switchToLatest]
     ignore:nil];
    
    [[[[[[self didBecomeActiveSignal]
      flattenMap:^RACStream *(id value) {
          return [self authorizationStatusSignal];
      }]
      filter:^BOOL(id value) {
          return value;
      }] flattenMap:^RACStream *(id value) {
          return [[self.services getParseConnection] refreshPostsForCurrentLocation:self.currentLocation];
      }]
     flattenMap:^RACSignal *(id _) {
         return [self.refreshPosts execute:nil];
     }] subscribeNext:^(id x) {
         
     }];
}




-(RACSignal *)refreshPostsSignalForCurrentLocation{
    return [[self.services getParseConnection] refreshPostsForCurrentLocation:self.currentLocation];
}

-(RACSignal *)authorizationStatusSignal{
    return [[[SpreeLocationManager sharedManager] rac_signalForAuthorizationStatusUpdate] map:^id(id value) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
            return @NO;
        } else {
            return @YES;
        }
    }];
}


@end
