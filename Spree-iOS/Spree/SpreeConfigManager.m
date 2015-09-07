//
//  SpreeConfigManager.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/27/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SpreeConfigManager.h"
#import <Parse/PFConfig.h>

@interface SpreeConfigManager ()

@property (nonatomic, strong) PFConfig *config;
@property (nonatomic, strong) NSDate *configLastFetchedDate;

@end

@implementation SpreeConfigManager

#pragma mark -
#pragma mark Init

+ (instancetype)sharedManager {
    static SpreeConfigManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchConfigIfNeeded)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Fetch

- (void)fetchConfigIfNeeded {
    static const NSTimeInterval configRefreshInterval = 60.0 * 60.0; // 1 hour
    
    if (self.config == nil ||
        self.configLastFetchedDate == nil ||
        [self.configLastFetchedDate timeIntervalSinceNow] * -1.0 > configRefreshInterval) {
        // Set the config to the cached version and start fetching new config
        self.config = [PFConfig currentConfig];
        
        // Set the date to current and use it as a flag that config fetch is in progress
        self.configLastFetchedDate = [NSDate date];
        
        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            if (error == nil) {
                // Yay, config was fetched
                self.config = config;
                self.configLastFetchedDate = [NSDate date];
            } else {
                // Remove the flag to indicate that we should refetch the config once again
                self.configLastFetchedDate = nil;
            }
        }];
    }
}

#pragma mark -
#pragma mark Parameters

-(NSArray *)campusBannerSlidesForNetworkCode:(NSString *)networkCode{
    NSString *bannerId = [NSString stringWithFormat:@"%@_banner", networkCode];
    NSMutableArray *bannerMetadata = [self.config[bannerId] mutableCopy];
    if (!bannerMetadata){
        bannerMetadata = [@[@{
            @"title":@"Welcome to Spree"
        }] mutableCopy];
    }
    return [bannerMetadata copy];
}

/* Parse examples
- (NSArray *)filterDistanceOptions {
    NSMutableArray *distanceOptions = [self.config[@"availableFilterDistances"] mutableCopy];
    if (!distanceOptions) {
        // No config value, fall back to the defaults
        distanceOptions = [@[ @(250.0), @(2000.0), @(5000.0) ] mutableCopy];
    }
    return [distanceOptions copy];
}

- (NSUInteger)postMaxCharacterCount {
    NSNumber *number = self.config[@"postMaxCharacterCount"];
    if (number == nil) {
        // No config value, fall back to the defaults
        return 140;
    }
    return [number unsignedIntegerValue];
}
*/

@end