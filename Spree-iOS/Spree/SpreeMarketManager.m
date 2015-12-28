//
//  SpreeMarketManager.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/27/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "SpreeMarketManager.h"
#import <MMPReactiveCoreLocation/MMPReactiveCoreLocation.h>

@interface SpreeMarketManager ()

@property NSArray *markets;
@property CLCircularRegion *currentReadRegion;
@property CLCircularRegion *currentWriteRegion;
@end

@implementation SpreeMarketManager

#pragma mark -
#pragma mark Init

+ (instancetype)sharedManager {
    static SpreeMarketManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.markets = [[NSArray alloc] initWithObjects:@{@"name":@"Bay Area", @"UUID":@"1", @"read_center_lat": @(37.569267), @"read_center_long": @(-122.177065), @"read_radius":@160934, @"write_center_lat":@(37.349668), @"write_center_lat":@(-121.939057), @"write_radius" : @160934}, nil];
    }
    return self;
}

#pragma mark - 
#pragma Public Methods

- (NSArray *)marketsForLocation:(CLLocation *)location {
    
    NSMutableArray *marketList = [[NSMutableArray alloc] init];
    
     if (!self.markets) {
         return nil;
     } else {
         for (NSDictionary *market in self.markets){
             if ([[self readRegionFromMarket:market] containsCoordinate:location.coordinate]){
                 if (![marketList containsObject:market]){
                     [marketList addObject:market];
                 }
             }
             
             if ([[self writeRegionFromMarket:market] containsCoordinate:location.coordinate]){
                 if (![marketList containsObject:market]){
                     [marketList addObject:market];
                 }
             }
             
         }
         return marketList;
     }
}


-(CLCircularRegion *)writeRegionFromLocation:(CLLocation *)location{
    for (NSDictionary *market in self.markets){
        CLCircularRegion *region = [self writeRegionFromMarket:market];
        if ([region containsCoordinate:location.coordinate]){
            return region;
        }
    }
    return nil;
}

-(CLCircularRegion *)readRegionFromLocation:(CLLocation *)location{
    NSLog(@"location: %@", location);
    for (NSDictionary *market in self.markets){
        CLCircularRegion *region = [self readRegionFromMarket:market];
        if ([region containsCoordinate:location.coordinate]){
            return region;
        }
    }
    return nil;
}

#pragma mark -
#pragma Private Methods

- (CLCircularRegion *)readRegionFromMarket:(NSDictionary *)market{
    
    NSNumber* centerLat = [market objectForKey: @"read_center_lat"];
    NSNumber* centerLong = [market objectForKey: @"read_center_long"];
    
    CLLocationCoordinate2D readCenter =  CLLocationCoordinate2DMake([centerLat doubleValue], [centerLong doubleValue]);
    
    NSNumber* readRadius = market[@"read_radius"];
    
    CLCircularRegion *readRegion = [[CLCircularRegion alloc] initWithCenter:readCenter radius:[readRadius doubleValue] identifier:market[@"name"]];
    
    return readRegion;

}

- (CLCircularRegion *)writeRegionFromMarket:(NSDictionary *)market{
    
    NSNumber* centerLat = [market objectForKey: @"write_center_lat"];
    NSNumber* centerLong = [market objectForKey: @"write_center_long"];
    
    CLLocationCoordinate2D writeCenter =  CLLocationCoordinate2DMake([centerLat doubleValue], [centerLong doubleValue]);
    
    NSNumber* writeRadius = market[@"write_radius"];
    
    CLCircularRegion *writeRegion = [[CLCircularRegion alloc] initWithCenter:writeCenter radius:[writeRadius doubleValue] identifier:market[@"name"]];
    
    return writeRegion;
    
}

@end
