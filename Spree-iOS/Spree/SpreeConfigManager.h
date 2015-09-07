//
//  SpreeConfigManager.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/27/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpreeConfigManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchConfigIfNeeded;
//
//- (NSArray *)filterDistanceOptions;
//- (NSUInteger)postMaxCharacterCount;

-(NSArray *)campusBannerSlidesForNetworkCode:(NSString *)networkCode;

@end
