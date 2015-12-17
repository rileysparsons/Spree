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
    
    [[SpreeLocationManager sharedManager] requestWhenInUseAuthorization];
    
    RAC(self, currentLocation) = [[[SpreeLocationManager sharedManager] rac_signalForAllLocationUpdates] map:^id(NSArray *array) {
        NSLog(@"%@", [array objectAtIndex:0]);
        return [array objectAtIndex:0];
    }];
    self.refreshPosts = [[RACCommand alloc] initWithEnabled:nil signalBlock:^RACSignal *(id input) {
        return [self refreshPostsSignalForCurrentLocation];
    }];

    [[[self.refreshPosts executionSignals] flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(id x) {
        
    }];
}


-(RACSignal *)refreshPostsSignalForCurrentLocation{
    return [[self.services getParseConnection] refreshPostsForCurrentLocation:self.currentLocation];
}

@end
