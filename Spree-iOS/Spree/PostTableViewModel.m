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
    
    RAC(self, currentLocation) = [[SpreeLocationManager sharedManager] rac_signalForCurrentLocation];

    RAC(self, locationServicesAuthorized) = [self authorizationStatusSignal];
    
    @weakify(self);
    self.refreshPosts = [[RACCommand alloc] initWithEnabled:nil signalBlock:^RACSignal *(id input) {
        RACSignal *itemsSignal = [self refreshPostsSignalForCurrentLocation];
        [itemsSignal subscribeNext:^(NSArray *returnedPosts) {
            @strongify(self);
            // Do stuff...
            self.posts = returnedPosts;
        }];
        return itemsSignal;
    }];
    
    self.requestLocationServices = [[RACCommand alloc] initWithEnabled:nil signalBlock:^RACSignal *(id input) {
        NSLog(@"called it");
        [[SpreeLocationManager sharedManager] requestWhenInUseAuthorization];
        return [RACSignal empty];
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
