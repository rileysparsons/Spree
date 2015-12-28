//
//  SpreeMarketManager.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/27/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpreeMarketManager : NSObject

+ (instancetype)sharedManager;

- (NSArray *)marketsForLocation:(CLLocation *)location;

-(CLCircularRegion *)writeRegionFromLocation:(CLLocation *)location;

-(CLCircularRegion *)readRegionFromLocation:(CLLocation *)location;

@end
